with open("c:/Users/simon/project/admin.html", "r") as f:
    content = f.read()

old = '    sell_type:document.getElementById(\'pfSellType\').value, tags\n    card_keys: (document.getElementById("pfCardKeys").value.trim() || "").split("\n").filter(function(k){ return k.trim(); }),'
new = '    sell_type:document.getElementById(\'pfSellType\').value, tags,\n    card_keys: (document.getElementById("pfCardKeys").value.trim() || "").split("\n").filter(function(k){ return k.trim(); }),'

if old in content:
    content = content.replace(old, new)
    with open("c:/Users/simon/project/admin.html", "w") as f:
        f.write(content)
    print("Fixed admin.html")
else:
    print("Old string not found, checking...")
    # Try to find the broken version
    if 'card_keys: (document.getElementById("pfCardKeys").value.trim() || "").split("' in content:
        print("Found broken card_keys line")
        import re
        pattern = r'sell_type:document\.getElementById\(\x27pfSellType\x27\)\.value, tags\n    card_keys:.*?filter\(function\(k\)\{ return k\.trim\(\); \}\),'
        content = re.sub(pattern, new, content, flags=re.DOTALL)
        with open("c:/Users/simon/project/admin.html", "w") as f:
            f.write(content)
        print("Fixed with regex")
