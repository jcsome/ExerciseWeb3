from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend
from cryptography.exceptions import InvalidSignature

# 1. Generate RSA key pair (private and public key)
def generate_key_pair():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    public_key = private_key.public_key()

    return private_key, public_key

# 2. Sign data with private key
def sign_data(private_key, data):
    signature = private_key.sign(
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    return signature

# 3. Verify signature with public key
def verify_signature(public_key, data, signature):
    try:
        public_key.verify(
            signature,
            data,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except InvalidSignature:
        return False

# 4. Main function to demonstrate RSA signing and verification
if __name__ == "__main__":
    # Step 1: Generate the RSA key pair
    private_key, public_key = generate_key_pair()

    # Serialize and save keys (optional, for reference)
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )

    public_pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    with open("private_key.pem", "wb") as f:
        f.write(private_pem)
    
    with open("public_key.pem", "wb") as f:
        f.write(public_pem)

    # Step 2: Create a nickname + nonce (POW)
    nickname = "SJC1902"
    nonce = "123456"
    pow_data = (nickname + nonce).encode('utf-8')  # Convert to bytes

    # Step 3: Sign the data using the private key
    signature = sign_data(private_key, pow_data)
    print("Signature:", signature)

    # Step 4: Verify the signature using the public key
    is_valid = verify_signature(public_key, pow_data, signature)
    if is_valid:
        print("Signature is valid!")
    else:
        print("Signature is invalid!")
