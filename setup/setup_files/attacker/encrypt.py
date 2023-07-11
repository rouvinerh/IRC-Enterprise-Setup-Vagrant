from hashlib import md5
from Cryptodome.Cipher import AES
from os import urandom
import sys

def derive_key_and_iv(password, salt, key_length, iv_length):
    d = d_i = b''
    while len(d) < key_length + iv_length:
        d_i = md5(d_i + str.encode(password) + salt).digest() 
        d += d_i
    return d[:key_length], d[key_length:key_length+iv_length]

def encrypt(in_file, out_file, password, key_length=32):
    bs = AES.block_size 
    salt = urandom(bs) 
    key, iv = derive_key_and_iv(password, salt, key_length, bs)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    out_file.write(salt)
    finished = False

    while not finished:
        chunk = in_file.read(1024 * bs) 
        if len(chunk) == 0 or len(chunk) % bs != 0:
            padding_length = (bs - len(chunk) % bs) or bs
            chunk += str.encode(padding_length * chr(padding_length))
            finished = True
        out_file.write(cipher.encrypt(chunk))

def decrypt(in_file, out_file, password, key_length=32):
    bs = AES.block_size
    salt = in_file.read(bs)
    key, iv = derive_key_and_iv(password, salt, key_length, bs)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    next_chunk = ''
    finished = False
    while not finished:
        chunk, next_chunk = next_chunk, cipher.decrypt(in_file.read(1024 * bs))
        if len(next_chunk) == 0:
            padding_length = chunk[-1]
            chunk = chunk[:-padding_length]
            finished = True 
        out_file.write(bytes(x for x in chunk)) 

def main():
	if len(sys.argv) != 4:
		print("Usage: python3 <in_file> <out_file> <enc/dec>")
		sys.exit()
	in_file = sys.argv[1]
	out_file = sys.argv[2]
	mode = sys.argv[3]

	password = 'hrtennnx9muGhexwWG7n87k4q3A1OM'
	
	if mode == 'enc':
		with open (in_file, 'rb') as input_file, open(out_file,'wb') as output_file:
			encrypt(input_file, output_file, password)
	elif mode == 'dec':
		with open (in_file, 'rb') as input_file, open(out_file,'wb') as output_file:
			decrypt(input_file, output_file, password)

if __name__ == '__main__':
    main()