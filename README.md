# tabtab
Tabulated tables for MediaWiki markup.

Use as
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
