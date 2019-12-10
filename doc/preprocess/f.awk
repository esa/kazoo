BEGIN {
    inside=0;
    insideSection=0;
}
/^=== / {
    fname=$2;
    order = "output/order.txt";
    print fname > order;
    insideSection=1;
}
/class.*wikitable/ {
    inside=1;
}
/^\|}/ {
    inside=0;
    insideSection=2;
    print $0 > fname ;
}
{
    if (inside && insideSection == 1) {
        print $0 > fname;
    }
    if (insideSection == 1 && !inside) {
        pre = sprintf("%s.pre", fname);
        print $0 > pre;
    }
    if (insideSection == 2 && !inside) {
        post = sprintf("%s.post", fname);
        print $0 > post;
    }
}
