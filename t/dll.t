=for Haskell example
    data Node = Empty | Node Int Node Node
        deriving Show
        
    x = let y = Node 2 x y
            z = Node 3 y Empty
         in Node 1 Empty y

=cut

use MooseX::Declare;
use Moose::Util::TypeConstraints;

BEGIN { role_type 'DLL' };
role DLL { }

class DLL::Empty with DLL { }
class DLL::Node with DLL {
    has val => (
        isa => 'Any',
        is  => 'ro',
    );
    has prev => (
        isa => 'DLL',
        # isa => 'Any',
        is => 'ro',
    );
    has next => (
        isa => 'DLL',
        # isa => 'Any',
        is => 'ro',
    );
}

package main;
use Test::More;

use Data::Dumper;
use Data::Thunk;

sub empty { 
    DLL::Empty->new 
}

# this is not very pretty (damn this lack of typechecking and pervasive
# laziness!)
my $list = do {
    my ($x, $y, $z);
    $x = lazy_new 'DLL::Node', args=>[val=>1, prev=>empty, next=>(lazy_object {$y} class=>'DLL::Node')];
    $y = lazy_new 'DLL::Node', args=>[val=>2, prev=>(lazy_object {$x} class=>'DLL::Node'), next=>(lazy_object {$z} class=>'DLL::Node')];
    $z = lazy_new 'DLL::Node', args=>[val=>3, prev=>(lazy_object {$y} class=>'DLL::Node'), next=>empty];
    $x;
};

is $list->val,                          1;
is $list->next->val,                    2;
is $list->next->next->val,              3;
is $list->next->prev->val,              1;
is $list->next->next->prev->val,        2;
is $list->next->next->prev->next->val,  3;

done_testing;
