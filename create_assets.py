import os

dest_dir = r"C:\Users\ASUS\.gemini\antigravity\scratch\simwar_warung_azzam\assets"
os.makedirs(dest_dir, exist_ok=True)

svgs = {
    "buah-1.svg": """<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="6.5" cy="6.5" r="6.5" fill="#F8B62B"/>
</svg>""",

    "buah-2.svg": """<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="6.5" cy="6.5" r="6.5" fill="#C8401E"/>
</svg>""",

    "daun-1.svg": """<svg width="28" height="28" viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="14" cy="14" r="14" fill="#23794F"/>
</svg>""",

    "daun-2.svg": """<svg width="20" height="26" viewBox="0 0 20 26" fill="none" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="10" cy="13" rx="10" ry="13" fill="#23794F" fill-opacity="0.85"/>
</svg>""",

    "dekorasi.svg": """<svg width="390" height="430" viewBox="0 0 390 430" fill="none" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#clip0_2095_149)">
<circle cx="195" cy="325" r="155" fill="#23794F" fill-opacity="0.28"/>
<circle cx="195" cy="325" r="110" fill="#23794F" fill-opacity="0.22"/>
<circle cx="55" cy="75" r="124.25" stroke-width="1.5" stroke="#F4EFE0" stroke-opacity="0.1"/>
<circle cx="350" cy="140" r="99.25" stroke-width="1.5" stroke="#F4EFE0" stroke-opacity="0.1"/>
<circle cx="350" cy="140" r="79.25" stroke-width="1.5" stroke="#F4EFE0" stroke-opacity="0.08"/>
<circle cx="333.5" cy="125.5" r="3.5" fill="#F8B62B" fill-opacity="0.9"/>
<circle cx="300.5" cy="180.5" r="2.5" fill="#F4EFE0" fill-opacity="0.6"/>
<circle cx="49" cy="199" r="3" fill="#F8B62B" fill-opacity="0.7"/>
<circle cx="354" cy="216" r="2" fill="#F4EFE0" fill-opacity="0.5"/>
<circle cx="30" cy="264" r="2" fill="#F4EFE0" fill-opacity="0.5"/>
</g>
<defs>
<clipPath id="clip0_2095_149">
<rect width="390" height="430" fill="white"/>
</clipPath>
</defs>
</svg>""",

    "gagang-pintu.svg": """<svg width="6" height="6" viewBox="0 0 6 6" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="3" cy="3" r="3" fill="#F8B62B"/>
</svg>""",

    "ikon-kunci.svg": """<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M6 8.25V5.25C6 4.45435 6.31607 3.69129 6.87868 3.12868C7.44129 2.56607 8.20435 2.25 9 2.25C9.79565 2.25 10.5587 2.56607 11.1213 3.12868C11.6839 3.69129 12 4.45435 12 5.25V8.25M3.75 8.25H14.25V15.75H3.75V8.25Z" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" stroke="#6E7468"/>
</svg>""",

    "ikon-mata.svg": """<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M0.75 9C0.75 9 3.75 3 9 3C14.25 3 17.25 9 17.25 9C17.25 9 14.25 15 9 15C3.75 15 0.75 9 0.75 9ZM9 11.25C9.59674 11.25 10.169 11.0129 10.591 10.591C11.0129 10.169 11.25 9.59674 11.25 9C11.25 8.40326 11.0129 7.83097 10.591 7.40901C10.169 6.98705 9.59674 6.75 9 6.75C8.40326 6.75 7.83097 6.98705 7.40901 7.40901C6.98705 7.83097 6.75 8.40326 6.75 9C6.75 9.59674 6.98705 10.169 7.40901 10.591C7.83097 11.0129 8.40326 11.25 9 11.25Z" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" stroke="#6E7468"/>
</svg>""",

    "ikon-stok.svg": """<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 21L3 16V8L12 3L21 8V16L12 21ZM21 8L12 13M3 8L12 13M12 21V13" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="#14372D"/>
</svg>""",

    "ikon-telepon.svg": """<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3.75 3H6.75L8.25 6.75L6.375 7.875C7.17822 9.50365 8.49635 10.8218 10.125 11.625L11.25 9.75L15 11.25V14.25C15 14.6478 14.842 15.0294 14.5607 15.3107C14.2794 15.592 13.8978 15.75 13.5 15.75C10.5744 15.5722 7.81512 14.3299 5.74262 12.2574C3.67013 10.1849 2.42779 7.42555 2.25 4.5C2.25 4.10218 2.40804 3.72064 2.68934 3.43934C2.97064 3.15804 3.35218 3 3.75 3Z" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" stroke="#6E7468"/>
</svg>""",

    "lengkung-1.svg": """<svg width="40" height="24" viewBox="0 0 40 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="20" cy="12" rx="20" ry="12" fill="#F8B62B"/>
</svg>""",

    "lengkung-2.svg": """<svg width="40" height="24" viewBox="0 0 40 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<ellipse cx="20" cy="12" rx="20" ry="12" fill="white"/>
</svg>""",

    "status-bar.svg": """<svg width="62" height="12" viewBox="0 0 62 12" fill="none" xmlns="http://www.w3.org/2000/svg">
<g clip-path="url(#clip0_2073_3855)">
<path d="M2 8H1C0.447715 8 0 8.44772 0 9V11C0 11.5523 0.447715 12 1 12H2C2.55228 12 3 11.5523 3 11V9C3 8.44772 2.55228 8 2 8Z" fill="#F4EFE0"/>
<path d="M7 5.5H6C5.44772 5.5 5 5.94772 5 6.5V11C5 11.5523 5.44772 12 6 12H7C7.55228 12 8 11.5523 8 11V6.5C8 5.94772 7.55228 5.5 7 5.5Z" fill="#F4EFE0"/>
<path d="M12 3H11C10.4477 3 10 3.44772 10 4V11C10 11.5523 10.4477 12 11 12H12C12.5523 12 13 11.5523 13 11V4C13 3.44772 12.5523 3 12 3Z" fill="#F4EFE0"/>
<path d="M17 0.5H16C15.4477 0.5 15 0.947715 15 1.5V11C15 11.5523 15.4477 12 16 12H17C17.5523 12 18 11.5523 18 11V1.5C18 0.947715 17.5523 0.5 17 0.5Z" fill="#F4EFE0"/>
<path d="M24 4.5C24.5631 3.86156 25.2555 3.35024 26.0314 3C26.8072 2.64976 27.6487 2.46863 28.5 2.46863C29.3513 2.46863 30.1928 2.64976 30.9686 3C31.7445 3.35024 32.4369 3.86156 33 4.5M26 7C26.2998 6.62482 26.6801 6.32192 27.1129 6.11375C27.5457 5.90559 28.0198 5.7975 28.5 5.7975C28.9802 5.7975 29.4543 5.90559 29.8871 6.11375C30.3199 6.32192 30.7002 6.62482 31 7" stroke-width="1.4" stroke-linecap="round" stroke="#F4EFE0"/>
<path d="M28.5 10.6C29.0523 10.6 29.5 10.1523 29.5 9.59998C29.5 9.04769 29.0523 8.59998 28.5 8.59998C27.9477 8.59998 27.5 9.04769 27.5 9.59998C27.5 10.1523 27.9477 10.6 28.5 10.6Z" fill="#F4EFE0"/>
<path d="M41.2 0.5H55.8C57.5673 0.5 59 1.93269 59 3.7V8.3C59 10.0673 57.5673 11.5 55.8 11.5H41.2C39.4327 11.5 38 10.0673 38 8.3V3.7C38 1.93269 39.4327 0.5 41.2 0.5Z" stroke="#F4EFE0" stroke-opacity="0.5"/>
<path d="M52.2 2.5H41.8C40.8059 2.5 40 3.30589 40 4.3V7.7C40 8.69411 40.8059 9.5 41.8 9.5H52.2C53.1941 9.5 54 8.69411 54 7.7V4.3C54 3.30589 53.1941 2.5 52.2 2.5Z" fill="#F4EFE0"/>
<path d="M60.8 4H60.7C60.3134 4 60 4.3134 60 4.7V7.3C60 7.6866 60.3134 8 60.7 8H60.8C61.1866 8 61.5 7.6866 61.5 7.3V4.7C61.5 4.3134 61.1866 4 60.8 4Z" fill="#F4EFE0" fill-opacity="0.5"/>
</g>
<defs>
<clipPath id="clip0_2073_3855">
<rect width="62" height="12" fill="white"/>
</clipPath>
</defs>
</svg>""",

    "toples-1.svg": """<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="7" cy="7" r="7" fill="#F8B62B"/>
</svg>""",

    "toples-2.svg": """<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="7" cy="7" r="7" fill="#C8401E"/>
</svg>""",

    "toples-3.svg": """<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="7" cy="7" r="7" fill="#F4EFE0"/>
</svg>""",

    "toples-4.svg": """<svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="7" cy="7" r="7" fill="#23794F"/>
</svg>"""
}

print(f"Writing {len(svgs)} SVG files to {dest_dir}...")
for name, code in svgs.items():
    filepath = os.path.join(dest_dir, name)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(code.strip() + "\n")
    print(f"  Wrote {name} ({len(code)} bytes)")

print("ALL 17 SVGs CREATED SUCCESSFULLY!")
