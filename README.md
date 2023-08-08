<img src="./assets/logo.png" width="100" height="100">

# VatchexGreece

An Elixir library for converting Greek text to [Greeklish](https://en.wikipedia.org/wiki/Greeklish).

## Installation

The package is [available in Hex](https://hex.pm/packages/greeklix) and can be installed
by adding `greeklix` to your list of dependencies in `mix.exs`. 


```elixir
def deps do
  [
    {:greeklix, "~> 0.1.0"},
  ]
end
```

## Usage

Apply `Greeklix.convert/2` to a string.

Optionally, provide an integer argument to indicate the Greeklish variant. The default is variant 0, which is the most common Greeklish spelling. Larger values (values above 3 are clamped to 3) apply progressively shorter, more phonetic, and more inane Greeklish substitutions ("8" for "θ", etc.)

Any grapheme not in the substitution rules will be left unchanged. Use `Greeklix.get_rules/0` to see the substitution rules.

### Example 

`t = "φραπεδοκράτορας (-άτωρ). Αυτός που περιφέρεται μονίμως με έναν φραπέ ανά χείρας. Τον συναντάμε αρκετά συχνά και σε εργασιακούς χώρους υπό τη μορφή άνετου και απελευθερωμένου εργαζόμενου."`

| `variant` | `Greeklix.convert(t, variant)` |
|-----------|-----------|
| 0 (default) | `frapedokratoras (-atwr). Autos pou periferetai monimws me enan frape ana xeiras. Ton synantame arketa syxna kai se ergasiakous xwrous ypo th morfh anetou kai apeleutherwmenou ergazomenou.` |
| 1 | `phrapedokratoras (-ator). Aftos poy peripherete monimos me enan phrape ana hiras. Ton sunadame arketa suhna ke se ergasiakoys horoys upo ti morphi anetoy ke apelef8eromenoy ergazomenoy.` |
| 2 | `phrapedokratoras (-atvr). Avtos pu peripherete monimvs me enan phrape ana chiras. Ton sinadame arketa sichna ke se ergasiakus chvrus ipo ti morphi anetu ke apelev8ervmenu ergazomenu.` |
| 3 | `phrapedokratoras (-atvr). Aytos pu peripherete monimvs me enan phrape ana chiras. Ton sinadame arketa sichna ke se ergasiakus chvrus ipo ti morphi anetu ke apeley8ervmenu ergazomenu.` |
| > 3 | *same as `variant = 3`*  |


## Documentation

The docs can be found at <https://hexdocs.pm/greeklix>.


## Credits

Inspired by [python-greeklish](https://github.com/Giaola/python-greeklish).