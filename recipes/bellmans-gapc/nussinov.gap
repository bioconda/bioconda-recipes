
signature Nuss(alphabet, answer) {

  answer nil(void);
  answer right(answer, alphabet);
  answer pair(alphabet, answer, alphabet);
  answer split(answer, answer);
  choice [answer] h([answer]);

}

algebra pretty implements Nuss(alphabet = char, answer = string)
{
  string nil(void)
  {
    string r;
    return r;
  }

  string right(string a, char c)
  {
    string r;
    append(r, a);
    append(r, '.');
    return r;
  }

  string pair(char c, string m, char d)
  {
    string r;
    append(r, '(');
    append(r, m);
    append(r, ')');
    return r;
  }

  string split(string l, string r)
  {
    string res;
    append(res, l);
    append(res, r);
    return res;
  }

  choice [string] h([string] l)
  {
    return l;
  }
  
}

algebra bpmax implements Nuss(alphabet = char, answer = int)
{
  int nil(void)
  {
    return 0;
  }

  int right(int a, char c)
  {
    return a;
  }

  int pair(char c, int m, char d)
  {
    return m + 1;
  }

  int split(int l, int r)
  {
    return l + r;
  }

  choice [int] h([int] l)
  {
    return list(maximum(l));
  }
  
}

algebra bpmax2 extends bpmax
{
  kscoring choice [int] h([int] l)
  {
    int x = maximum(l);
    [int] r;
    push_back(r, x);
    if (x > 0)
      push_back(r, x-1);
    return r;
  }
}

algebra count implements Nuss(alphabet = char, answer = int)
{
  int nil(void)
  {
    return 1;
  }

  int right(int a, char c)
  {
    return a;
  }

  int pair(char c, int m, char d)
  {
    return m;
  }

  int split(int l, int r)
  {
    return l * r;
  }

  choice [int] h([int] l)
  {
    return list(sum(l));
  }
  
}


grammar nussinov uses Nuss (axiom=start) {

  tabulated { start, bp }

  start = nil(EMPTY) |
          right(start, CHAR) |
          split(start, bp) # h ;

  bp = pair(CHAR, start, CHAR) with char_basepairing ;


}

instance pretty = nussinov ( pretty ) ;

instance bpmax = nussinov ( bpmax ) ;

instance bpmaxpp = nussinov ( bpmax * pretty ) ;

instance count = nussinov ( count ) ;

instance bpmaxcnt = nussinov ( bpmax * count ) ;

instance bpmax1pp = nussinov ( bpmax . pretty ) ;

instance kbpmaxpp = nussinov ( bpmax2 * pretty ) ;


