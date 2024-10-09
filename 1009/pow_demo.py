import hashlib
import time

CHECK_0_NUMS = 6

def find_nonce():
    # time start
    start_time = time.time()
    
    base_string = "crazychat"
    nonce = 0
    
    while True:
        # concat base_string and nonce
        input_string = base_string + str(nonce)
        # cal SHA-256 value
        sha256_hash = hashlib.sha256(input_string.encode()).hexdigest()
        
        # check 0 nums
        if sha256_hash[:CHECK_0_NUMS] == "0"*CHECK_0_NUMS:
            # time end
            end_time = time.time()
            elapsed_time = end_time - start_time
            print(f"conditional nonce: {nonce}")
            print(f"hash value: {sha256_hash}")
            print(f"time consume: {elapsed_time:.6f} s")
            break
        
        # contemp next nonce
        nonce += 1

find_nonce()
