#include <sharg/all.hpp>

int main(int argc, char ** argv)
{
    int val{};

    sharg::parser parser{"Eat-Me-App", argc, argv};
    parser.add_subsection("Eating Numbers");
    parser.add_option(val, sharg::config{.short_id = 'i', .long_id = "int", .description = "Desc."});
    parser.parse();

    return 0;
}
