bakdrive interaction example/example_donor_input.txt -o example/donor_interaction
bakdrive driver example/donor_interaction -o example/donor_drivers
bakdrive fmt_donor example/example_fmt_input.txt -o example/fmt_donor_output
bakdrive fmt_driver example/example_disease_input.txt -i example/donor_drivers/driver_nodes.3layer.str02.txt -o example/fmt_driver_output
bakdrive fmt_only example/fmt_driver_output/disease1_species_drivers -o example/disease1_drivers_fmt_only


