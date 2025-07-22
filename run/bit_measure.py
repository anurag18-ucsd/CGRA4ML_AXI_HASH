import numpy as np
def hex_string_to_binary_string(hex_array):
    out_array=[0]*len(hex_array)
    for i in range(len(hex_array)):
        out_array[i] = bin(int(hex_array[i], 16))[2:].zfill(len(hex_array[i]) * 4)
    return out_array

def read_and_split_hex64(file_path):
    # Array to store the split 32-bit values
    hex_array = []
    try:
        # Open the file and read each line
        with open(file_path, 'r') as file:
            for line in file:
                # Remove whitespace and parse the 64-bit hexadecimal value
                hex64 = line.strip()
                if len(hex64) > 0:
                    # Convert to an integer
                    value = hex64
                    # Append both parts as hexadecimal to the array
                    hex_array.append(value)
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except ValueError as e:
        print(f"Error: Invalid value in the file. Details: {e}")

    return hex_array

y=read_and_split_hex64("../run/vectors/output_hashing.txt")
bin_weights=hex_string_to_binary_string(y)
weight_counts=[0]*len(bin_weights[0])
for j in range(len(bin_weights)):
    for i in range(len(bin_weights[j])):
        weight_counts[i]=weight_counts[i]+int(bin_weights[j][i])
weight_probs=np.array(weight_counts)/len(bin_weights)
print(len(weight_probs))
print(len(bin_weights[0]))
print(y[0])
#print(weight_probs)
argsort=np.argsort(weight_probs)
sorted=np.sort(weight_probs)
print(argsort[0:5])
print(sorted[0:5])
print(argsort[-5:])
print(sorted[-5:])