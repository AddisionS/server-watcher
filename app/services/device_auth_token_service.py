import secrets

def generate_auth_token()->str:
    return secrets.token_urlsafe(32)