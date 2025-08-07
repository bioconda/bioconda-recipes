from privateer import privateer_core as pvt


print(dir(pvt))
wurcs = pvt.print_wurcs("tests/test_data/2h6o_carbremediation.pdb")
print(wurcs)
