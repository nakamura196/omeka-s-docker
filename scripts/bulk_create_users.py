#!/usr/bin/env python3
"""
Omeka S Bulk User Management Script
Creates or deletes multiple users in Omeka S using the REST API

Requirements:
    pip install requests python-dotenv
"""

import sys
import json
import csv
import argparse
import getpass
import os
from typing import List, Dict, Optional
from pathlib import Path

import requests

# Try to import python-dotenv
try:
    from dotenv import load_dotenv
    DOTENV_AVAILABLE = True
except ImportError:
    DOTENV_AVAILABLE = False


class OmekaSUserManager:
    """Manages user creation and deletion in Omeka S via API"""
    
    def __init__(self, base_url: str, key_identity: str, key_credential: str):
        """
        Initialize the Omeka S API client
        
        Args:
            base_url: Base URL of Omeka S installation (e.g., https://omeka.example.com)
            key_identity: API key identity
            key_credential: API key credential
        """
        self.base_url = base_url.rstrip('/')
        self.api_url = f"{self.base_url}/api"
        self.key_identity = key_identity
        self.key_credential = key_credential
        
    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> requests.Response:
        """Make authenticated API request"""
        url = f"{self.api_url}/{endpoint}"
        params = {
            'key_identity': self.key_identity,
            'key_credential': self.key_credential
        }
        
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        
        if method == 'GET':
            response = requests.get(url, params=params, headers=headers)
        elif method == 'POST':
            response = requests.post(url, params=params, json=data, headers=headers)
        elif method == 'DELETE':
            response = requests.delete(url, params=params, headers=headers)
        else:
            raise ValueError(f"Unsupported method: {method}")
            
        return response
    
    def test_connection(self) -> bool:
        """Test API connection and credentials"""
        try:
            response = self._make_request('GET', 'users')
            return response.status_code == 200
        except Exception as e:
            print(f"Connection test failed: {e}")
            return False
    
    def get_existing_users(self) -> List[Dict]:
        """Get list of existing users"""
        response = self._make_request('GET', 'users')
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"Failed to get users: {response.status_code} - {response.text}")
    
    def create_user(self, user_data: Dict) -> Dict:
        """
        Create a single user
        
        Args:
            user_data: Dictionary containing user information
                Required fields: email, name
                Optional fields: role, is_active, password
        """
        # Prepare user data for Omeka S API
        omeka_user = {
            "o:email": user_data['email'],
            "o:name": user_data.get('name', user_data['email']),
            "o:role": user_data.get('role', 'researcher'),
            "o:is_active": user_data.get('is_active', True)
        }
        
        # Add password if provided
        if 'password' in user_data and user_data['password']:
            omeka_user["o:password"] = user_data['password']
        
        response = self._make_request('POST', 'users', omeka_user)
        
        if response.status_code in [200, 201]:
            return response.json()
        else:
            raise Exception(f"Failed to create user {user_data['email']}: {response.status_code} - {response.text}")
    
    def bulk_create_users(self, users: List[Dict]) -> Dict:
        """
        Create multiple users
        
        Args:
            users: List of user dictionaries
            
        Returns:
            Dictionary with results summary
        """
        results = {
            'created': [],
            'failed': [],
            'skipped': []
        }
        
        # Get existing users to avoid duplicates
        try:
            existing_users = self.get_existing_users()
            existing_emails = {user.get('o:email') for user in existing_users}
        except Exception as e:
            print(f"Warning: Could not fetch existing users: {e}")
            existing_emails = set()
        
        for user in users:
            email = user.get('email')
            if not email:
                results['failed'].append({
                    'user': user,
                    'error': 'Missing email field'
                })
                continue
                
            if email in existing_emails:
                results['skipped'].append({
                    'user': user,
                    'reason': 'User already exists'
                })
                print(f"Skipping {email}: User already exists")
                continue
            
            try:
                created_user = self.create_user(user)
                results['created'].append(created_user)
                print(f"Created user: {email}")
            except Exception as e:
                results['failed'].append({
                    'user': user,
                    'error': str(e)
                })
                print(f"Failed to create {email}: {e}")
        
        return results
    
    def get_user_by_email(self, email: str) -> Optional[Dict]:
        """Get user by email address"""
        users = self.get_existing_users()
        for user in users:
            if user.get('o:email') == email:
                return user
        return None
    
    def delete_user(self, user_id: int) -> bool:
        """
        Delete a user by ID
        
        Args:
            user_id: The ID of the user to delete
            
        Returns:
            True if successful, False otherwise
        """
        response = self._make_request('DELETE', f'users/{user_id}')
        return response.status_code in [200, 204]
    
    def bulk_delete_users(self, emails: List[str]) -> Dict:
        """
        Delete multiple users by email
        
        Args:
            emails: List of email addresses to delete
            
        Returns:
            Dictionary with results summary
        """
        results = {
            'deleted': [],
            'not_found': [],
            'failed': []
        }
        
        for email in emails:
            user = self.get_user_by_email(email)
            if not user:
                results['not_found'].append(email)
                print(f"User not found: {email}")
                continue
            
            user_id = user.get('o:id')
            user_name = user.get('o:name', email)
            
            try:
                if self.delete_user(user_id):
                    results['deleted'].append({
                        'email': email,
                        'name': user_name,
                        'id': user_id
                    })
                    print(f"Deleted user: {email} (ID: {user_id})")
                else:
                    results['failed'].append({
                        'email': email,
                        'error': 'Delete request failed'
                    })
                    print(f"Failed to delete: {email}")
            except Exception as e:
                results['failed'].append({
                    'email': email,
                    'error': str(e)
                })
                print(f"Error deleting {email}: {e}")
        
        return results


def load_users_from_csv(filepath: str, mode: str = 'create') -> List[Dict]:
    """
    Load users from CSV file
    
    For create mode:
        Expected columns: email, name, role (optional), is_active (optional), password
    For delete mode:
        Expected columns: email
    """
    users = []
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if mode == 'delete':
                # For deletion, we only need email
                email = row.get('email', '').strip()
                if email:
                    users.append({'email': email})
            else:
                # For creation, we need full user data
                user = {
                    'email': row.get('email', '').strip(),
                    'name': row.get('name', '').strip(),
                }
                
                if 'role' in row and row['role']:
                    user['role'] = row['role'].strip()
                
                if 'is_active' in row:
                    user['is_active'] = row['is_active'].lower() in ['true', '1', 'yes', 'active']
                
                if 'password' in row and row['password']:
                    user['password'] = row['password'].strip()
                    
                users.append(user)
    
    return users




def load_env_file():
    """Load environment variables from .env file"""
    if not DOTENV_AVAILABLE:
        return False
    
    # Try multiple locations for .env file
    env_locations = [
        Path('.env'),  # Current directory
        Path(__file__).parent / '.env',  # Script directory
        Path(__file__).parent.parent / '.env',  # Parent directory (project root)
    ]
    
    for env_path in env_locations:
        if env_path.exists():
            load_dotenv(env_path)
            return True
    
    return False


def main():
    # Load .env file if available
    if DOTENV_AVAILABLE:
        load_env_file()
    
    parser = argparse.ArgumentParser(
        description='Bulk manage users in Omeka S (create or delete)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Create users from CSV file (credentials from .env or prompts)
  python bulk_create_users.py -u https://omeka.example.com -f users.csv
  
  # Delete users from CSV file
  python bulk_create_users.py -u https://omeka.example.com -f users_to_delete.csv --mode delete
  
  # With custom API credentials
  python bulk_create_users.py -u https://omeka.example.com -f users.csv --key-identity YOUR_KEY --key-credential YOUR_CREDENTIAL
  
  # Using .env file for configuration
  # Create a .env file with:
  #   OMEKA_API_URL=https://omeka.example.com
  #   OMEKA_API_KEY_IDENTITY=your_key_identity
  #   OMEKA_API_KEY_CREDENTIAL=your_key_credential
  
CSV format for creation (users.csv):
  email,name,role,is_active,password
  john@example.com,John Doe,researcher,true,ChangeMeNow123!
  jane@example.com,Jane Smith,author,true,SecurePass456!
  
CSV format for deletion (users_to_delete.csv):
  email
  john@example.com
  jane@example.com
        """
    )
    
    # URL can come from environment or command line
    default_url = os.getenv('OMEKA_API_URL')
    parser.add_argument('-u', '--url', default=default_url, 
                        help='Omeka S base URL (or set OMEKA_API_URL in .env)')
    parser.add_argument('-f', '--file', required=True, 
                        help='CSV file containing user data')
    parser.add_argument('--mode', choices=['create', 'delete'], default='create',
                        help='Operation mode: create or delete users (default: create)')
    parser.add_argument('--key-identity', 
                        help='API key identity (or set OMEKA_API_KEY_IDENTITY in .env)')
    parser.add_argument('--key-credential', 
                        help='API key credential (or set OMEKA_API_KEY_CREDENTIAL in .env)')
    
    args = parser.parse_args()
    
    # Get URL
    url = args.url
    if not url:
        print("Error: Omeka S URL is required. Provide it with -u flag or set OMEKA_API_URL in .env")
        sys.exit(1)
    
    # Get API credentials from args, env, or prompt
    key_identity = (
        args.key_identity or 
        os.getenv('OMEKA_API_KEY_IDENTITY') or 
        input("Enter API key identity: ")
    )
    
    key_credential = (
        args.key_credential or 
        os.getenv('OMEKA_API_KEY_CREDENTIAL') or 
        getpass.getpass("Enter API key credential: ")
    )
    
    # Initialize API client
    manager = OmekaSUserManager(url, key_identity, key_credential)
    
    # Test connection
    print(f"Testing connection to {url}...")
    if not manager.test_connection():
        print("Failed to connect to Omeka S API. Please check your URL and credentials.")
        sys.exit(1)
    print("Connection successful!")
    
    # Load users from CSV file
    if not args.file.endswith('.csv'):
        print("Error: Only CSV files are supported.")
        sys.exit(1)
    
    if args.mode == 'delete':
        # Delete mode
        users = load_users_from_csv(args.file, mode='delete')
        emails = [user['email'] for user in users]
        
        print(f"Loaded {len(emails)} email addresses for deletion from {args.file}")
        
        # Confirm before proceeding
        print("\nWARNING: This will permanently delete the following users:")
        for email in emails[:10]:  # Show first 10
            print(f"  - {email}")
        if len(emails) > 10:
            print(f"  ... and {len(emails) - 10} more")
        
        response = input(f"\nProceed with deleting {len(emails)} users? (y/N): ")
        if response.lower() != 'y':
            print("Operation cancelled.")
            sys.exit(0)
        
        # Delete users
        print("\nDeleting users...")
        results = manager.bulk_delete_users(emails)
        
        # Print summary
        print("\n" + "="*50)
        print("DELETION SUMMARY")
        print("="*50)
        print(f"Successfully deleted: {len(results['deleted'])}")
        print(f"Not found: {len(results['not_found'])}")
        print(f"Failed: {len(results['failed'])}")
        
        if results['not_found']:
            print("\nNot found users:")
            for email in results['not_found'][:10]:
                print(f"  - {email}")
            if len(results['not_found']) > 10:
                print(f"  ... and {len(results['not_found']) - 10} more")
        
        if results['failed']:
            print("\nFailed deletions:")
            for failure in results['failed']:
                print(f"  - {failure['email']}: {failure['error']}")
    else:
        # Create mode
        users = load_users_from_csv(args.file)
        
        print(f"Loaded {len(users)} users from {args.file}")
        
        # Confirm before proceeding
        response = input(f"Proceed with creating {len(users)} users? (y/N): ")
        if response.lower() != 'y':
            print("Operation cancelled.")
            sys.exit(0)
        
        # Create users
        print("\nCreating users...")
        results = manager.bulk_create_users(users)
        
        # Print summary
        print("\n" + "="*50)
        print("CREATION SUMMARY")
        print("="*50)
        print(f"Successfully created: {len(results['created'])}")
        print(f"Skipped (already exist): {len(results['skipped'])}")
        print(f"Failed: {len(results['failed'])}")
        
        if results['failed']:
            print("\nFailed users:")
            for failure in results['failed']:
                print(f"  - {failure['user'].get('email', 'Unknown')}: {failure['error']}")
    
    # Save results to file
    operation = 'delete' if args.mode == 'delete' else 'create'
    results_file = args.file.rsplit('.', 1)[0] + f'_{operation}_results.json'
    with open(results_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    print(f"\nDetailed results saved to: {results_file}")


if __name__ == '__main__':
    main()