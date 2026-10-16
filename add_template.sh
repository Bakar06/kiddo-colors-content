#!/bin/bash
# Kiddo Colors - Yeni boyama şablonu ekleme sihirbazı.
# Soruları cevapla, script resmi hazırlar, manifest.json'u günceller ve GitHub'a gönderir.
set -e
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "=== Kiddo Colors - Yeni Şablon Ekle ==="
echo

read -p "Resim dosyasının yolu (Finder'dan sürükle-bırak yapabilirsin): " IMG_PATH
IMG_PATH="${IMG_PATH%\'}"; IMG_PATH="${IMG_PATH#\'}"
IMG_PATH="${IMG_PATH/#\~/$HOME}"
if [ ! -f "$IMG_PATH" ]; then
  echo "Dosya bulunamadı: $IMG_PATH"
  exit 1
fi

read -p "Şablon kimliği (örn: unicorn2 - sadece harf, rakam, alt çizgi): " ID
if [ -z "$ID" ]; then echo "Kimlik boş olamaz."; exit 1; fi
if python3 -c "
import json
d = json.load(open('manifest.json'))
exit(0 if any(t['id'] == '$ID' for t in d['templates']) else 1)
"; then
  echo "Bu kimlik zaten kullanılıyor: $ID — başka bir isim dene."
  exit 1
fi

read -p "Kategori (free/animals/nature/vehicles... varsayılan: free): " CAT
CAT="${CAT:-free}"

echo
echo "Resmin adını 7 dilde gir (boş bırakırsan İngilizce ad kullanılır):"
read -p "  Türkçe: " N_TR
read -p "  İngilizce: " N_EN
read -p "  Almanca: " N_DE
read -p "  İspanyolca: " N_ES
read -p "  Fransızca: " N_FR
read -p "  Portekizce: " N_PT
read -p "  Rusça: " N_RU
N_EN="${N_EN:-$N_TR}"
N_DE="${N_DE:-$N_EN}"; N_ES="${N_ES:-$N_EN}"; N_FR="${N_FR:-$N_EN}"; N_PT="${N_PT:-$N_EN}"; N_RU="${N_RU:-$N_EN}"

read -p "Premium (kilitli) mi? (e/h, varsayılan h): " PREM
if [[ "$PREM" == "e" || "$PREM" == "E" ]]; then PREMIUM=true; else PREMIUM=false; fi

mkdir -p images
DEST="images/${ID}.png"

echo
echo "Resim 800x800'e ayarlanıyor..."
sips -s format png -z 800 800 "$IMG_PATH" --out "$DEST" >/dev/null

NAMES="${N_TR}|${N_EN}|${N_DE}|${N_ES}|${N_FR}|${N_PT}|${N_RU}"

python3 - "$ID" "$CAT" "$NAMES" "$PREMIUM" "images/${ID}.png" <<'PYEOF'
import json, sys
id_, cat, names, premium, image = sys.argv[1:6]
with open("manifest.json") as f:
    data = json.load(f)
data["templates"].append({
    "id": id_,
    "cat": cat,
    "names": names,
    "premium": premium == "true",
    "image": image,
})
with open("manifest.json", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF

echo
echo "manifest.json güncellendi. GitHub'a gönderiliyor..."
git add -A
git commit -q -m "Yeni şablon: ${ID}"
git push -q

echo
echo "Tamamdır! '${N_TR}' (${ID}) eklendi ve yayınlandı:"
echo "  https://github.com/Bakar06/kiddo-colors-content"
echo
echo "Uygulama bunu en geç 24 saat içinde (her açılışta günde bir kontrol ediyor) otomatik olarak alacak."
