# tabtab
Tabulated tables for MediaWiki markup.

## Usage
A file defined as following is a valid input to Tabtab
```
!
my-entry	second-entry	third-entry
match-entry	fifth-entry	sixth-entry
!
```

This will generate a mediawiki table

```wiki
{|class="table"
|my-entry||second-entry||third-entry
|-
|match-entry||fifth-entry||sixth-entry
|}
```

### To use the included tabtab.rb executable from the shell,
```bash
chmod +x tabtab.rb
./tabtab.rb sample_table.txt
```

### To call the transformer programmatically,
```ruby
require_relative 'lexer'

tabtab = Tabtab::Lexer.new
result = tabtab.gen_table(indata_string)
puts result
```
