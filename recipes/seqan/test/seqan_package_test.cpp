#include <iostream>

#include <seqan/align.h>
#include <seqan/sequence.h>
#include <seqan/version.h>

int main()
{
    using namespace seqan2;

    CharString seq("ABCDEFGHIJ");
    Gaps<CharString> gaps(seq);

    insertGaps(gaps, 2, 2);
    insertGap(gaps, 6);
    insertGap(gaps, 10);

    std::cout << "gaps\t" << gaps << '\n'
              << "seq \t" << seq << "\n\n";

    std::cout << "Version: "
              << SEQAN_VERSION_MAJOR << '.'
              << SEQAN_VERSION_MINOR << '.'
              << SEQAN_VERSION_PATCH << '\n';

    return 0;
}
