interface Doubler
{
  doubler(arg: string): string;
}

class Hoge implements Doubler
{
    doubler(arg: string)
    {
        return arg + " " + arg;
    }
}

class Foo extends Hoge
{
}

function greetHelper<T extends Doubler>(greeter: T, msg: string) {
    alert(greeter.doubler(msg));
}

function greet(msg: string)
{
    greetHelper(new Foo(), msg);
}

function test_my_func(m: number, n: number)
{
    return m * n;
}

function test_confirm(msg: string)
{
    if (confirm(msg)) {
        return "OKの場合";
    } else {
        return "キャンセルの場合";
    }
}

