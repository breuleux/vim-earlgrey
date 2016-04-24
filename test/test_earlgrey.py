from neovim_unittest import NeovimTestCase


class EarlGreyCase(NeovimTestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.nvim.command('setfiletype earlgrey')


class TestContribExamples(EarlGreyCase):
    CASES = (
        ('key x', {
            'egStatement': '1-3',
        }),
        ('key +x; key @x; key .x; key "x"; key 0', {
            'egDotString': '21-22',
            'egNumber': 38,
            'egOperator': '5,13',
            'egStatement': '1-3,9-11,17-19,25-27,34-36',
            'egString': '29-31',
        }),
        ('key (x); key [x]; key {x}', {
            'egGroup': '6,15,24',
            'egGroupDelimiter': '5,7,14,16,23,25',
            'egStatement': '1-3,10-12,19-21',
        }),
        ('nokey.x; nokey{x}', {
            'egGroup': 16,
            'egGroupDelimiter': '15,17',
            'egOperator': 6,
        }),
        ('key x + y', {
            'egOperator': 7,
            'egStatement': '1-3',
        }),
        ('key key x', {
            'egStatement': '1-3,5-7',
        }),
        ('x + key y', {
            'egOperator': 3,
            'egStatement': '5-7',
        }),
        ('nokey + x', {
            'egOperator': 7,
        }),
        ('key: x', {
            'egControlColon': 4,
            'egOperator?': 4,
            'egStatement': '1-3',
        }),
        ('key nokey: y', {
            'egControlColon': 10,
            'egStatement': '1-3',
        }),
        ('key x > nokey: z', {
            'egControlColon': 14,
            'egOperator': 7,
            'egStatement': '1-3',
        }),
        ('x + key nokey: z', {
            'egControlColon': 14,
            'egOperator': 3,
            'egStatement': '5-7',
        }),
        ('x + nokey: y', {
            'egControlColon': 10,
            'egOperator': 3,
        }),
        ('x mod nokey: y', {
            'egControlColon': 12,
            'egOperator': '3-5',
        }),
        ('x = key: y', {
            'egControlColon': 8,
            'egOperator': 3,
            'egStatement': '5-7',
        }),
        ('x each key: y', {
            'egControlColon': 11,
            'egOperator': '3-6',
            'egStatement': '8-10',
        }),
        ('nokey mod: y', {
            'egOperator': '7-10',
        }),
        ('await; break; chain; continue; else; expr-value; match; return; yield', {
            'egKeyword': '1-5,8-12,15-19,22-29,32-35,38-47,50-54,57-62,65-69',
        }),
        ('key-word: xyz', {
            'egControlColon': 9,
            'egStatement': '1-8',
        }),
        ('nokey - x: yz', {
            'egControlColon': 10,
            'egOperator': 7,
        }),
        ('beaches', {
        }),
        ('each-thing', {
        }),
        ('sleep-in', {
        }),
        ('before-each: xyz', {
            'egControlColon': 12,
            'egStatement': '1-11',
        }),
        ('is-great: xyz', {
            'egControlColon': 9,
            'egStatement': '1-8',
        }),
        ('key\n   x\n   nokey\n   x\n', {
            'egStatement': '1:1-3',
        }),
    )

    def test_cases(self):
        for string, spec in self.CASES:
            self.buffer = string
            self.assert_syntax_spec(spec)


class TestFunctionDefinitions(EarlGreyCase):
    CASES = (
        ('somefunc() =\n   x', {
            'egFunction': '1-8',
            'egGroupDelimiter': '9-10',
            'egOperator': '12',
        }),
        ('async somefunc() =\n   await x()', {
            'egFunction': '1:7-14',
            'egGroupDelimiter': '1:15-16,2:11-12',
            'egKeyword': '2:4-8',
            'egOperator': '1:18',
            'egStatement': '1:1-5',
        }),
        ('gen somefunc() =\n   yield x', {
            'egFunction': '1:5-12',
            'egGroupDelimiter': '1:13-14',
            'egKeyword': '2:4-8',
            'egOperator': '1:16',
            'egStatement': '1:1-3',
        }),
        ('macro somefunc() =\n   `x`', {
            'egCodeQuote': '2:5',
            'egCodeQuoteDelimiter': '2:4,2:6',
            'egFunction': '1:7-14',
            'egGroupDelimiter': '1:15-16',
            'egOperator': '1:18',
            'egStatement': '1:1-5',
        }),
    )

    def test_cases(self):
        for string, spec in self.CASES:
            self.buffer = string
            self.assert_syntax_spec(spec)


class TestVarious(EarlGreyCase):
    CASES = (
        ('2r1010101', {
            'egNumber': '3-9',
            'egRadixPrefix': '1-2',
        }),
        ("""'interpolated {{x = "abc", y = 2r10101}} string'""", {
            'egGroup': '17-18,20,26-29,31',
            'egGroupDelimiter': '16,39',
            'egInterpolationDelimiter': '15,40',
            'egNumber': '34-38',
            'egOperator': '19,30',
            'egRadixPrefix': '32-33',
            'egString': '21-25',
            'egStringTemplate': '1-14,41-48',
        }),
        ("`let x = 1`", {
            'egCodeQuote': '5-7,9',
            'egCodeQuoteDelimiter': '1,11',
            'egNumber': 10,
            'egOperator': 8,
            'egStatement': '2-4',
        }),
        ('new Date(1, 2, 3)', {
            'egGroup': '11-12,14-15',
            'egGroupDelimiter': '9,17',
            'egNumber': '10,13,16',
            'egStatement': '1-3',
            'egType': '5-8',
        }),
        ('if x:\n   y\nelse:\n   z\n', {
            'egControlColon': '1:5,3:5',
            'egKeyword': '1:1-2,3:1-4',
        }),
    )

    def test_cases(self):
        for string, spec in self.CASES:
            self.buffer = string
            self.assert_syntax_spec(spec)
