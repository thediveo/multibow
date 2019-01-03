package.path = "./sdcard/?.lua;./mock/?.lua;" .. package.path

require "mockkeybow"

print()
print("**** key 00...")
handle_key_00(true)
handle_key_00(false)
print()
print("**** key 03...")
handle_key_03(true)
handle_key_03(false)
print()

print("**** key 11...")
handle_key_11(true)
handle_key_11(false)

print("**** key 00...")
handle_key_00(true)
handle_key_00(false)

print()
print("**** key 11...")
handle_key_11(true)
handle_key_11(false)

print("**** key 00...")
handle_key_00(true)
handle_key_00(false)
