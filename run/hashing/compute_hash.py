from sha256 import *
import os
import struct
def read_and_split_hex64(file_path):
    # Array to store the split 32-bit values
    hex_array = [0x00000000]*32
    print(hex_array)
    try:
        # Open the file and read each line
        with open(file_path, 'r') as file:
            for line in file:
                # Remove whitespace and parse the 64-bit hexadecimal value
                hex64 = line.strip()
                if len(hex64) > 0:
                    # Convert to an integer
                    value = int(hex64, 16) 
                    
                    # Extract the upper and lower 32-bit parts
                    upper_32 = (value >> 32) & 0xFFFFFFFF
                    lower_32 = value & 0xFFFFFFFF
                    
                    # Append both parts as hexadecimal to the array
                    hex_array.append(int(f"0x{lower_32:08X}", 16))
                    hex_array.append(int(f"0x{upper_32:08X}", 16))
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except ValueError as e:
        print(f"Error: Invalid value in the file. Details: {e}")

    return hex_array

# File path to the text file containing 64-bit hexadecimal values
file_path = "output_hashing.txt"  #default file path

def compute_hash(file_path = file_path):
    # Read the file and process the data
    hex_array = read_and_split_hex64(file_path)
    print("Split 32-bit Hexadecimal Array:", len(hex_array))
    my_sha256 = SHA256(verbose=0)
        # TC1: NIST testcase with message "abc"
    my_sha256.init()
    file1= open("model_hash_input.txt", "w")
    file2= open("model_hash_output.bin", "wb")

    for i in range(int(len(hex_array)/16)):
        chunk = hex_array[i*16:i*16+16]
        chunk.reverse()
        concatenated_hex = (''.join(f"{value:08X}" for value in chunk)).lower()
        file1.write(concatenated_hex + "\n")
        my_sha256.next(chunk)
        my_digest = my_sha256.get_digest()
        #concatenated_hex_hash = (''.join(f"{value:08X}" for value in my_digest)).lower()
        file2.write(b''.join(struct.pack(">I", value) for value in my_digest))
    my_digest = my_sha256.get_digest()
    print(my_digest)
    
