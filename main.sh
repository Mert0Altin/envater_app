
#!/bin/bash

# Kullanıcı verilerini saklamak için dosya
KULLANICI_FILE="kullanicilar.txt"
DEPO_FILE="depo.csv"
LOG_FILE="log.csv"

# Varsayılan dosya kontrolü
if [ ! -f "$KULLANICI_FILE" ]; then
    touch "$KULLANICI_FILE"
    echo "admin:admin123:admin" >> "$KULLANICI_FILE"  # Varsayılan yönetici kullanıcı
fi

if [ ! -f "$DEPO_FILE" ]; then
    touch "$DEPO_FILE"  # Depo dosyası
fi

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"  # Log dosyası
fi

# Ürün Listeleme fonksiyonu
urun_listele() {
    if [ ! -f "$DEPO_FILE" ] || [ ! -s "$DEPO_FILE" ]; then
        zenity --info --title="Ürün Listeleme" --text="Envanterde ürün bulunmamaktadır."
    else
        urun_listesi=$(cat "$DEPO_FILE" | column -t -s ",")
        zenity --text-info --title="Ürün Listeleme" --width=600 --height=400 --filename=<(echo "$urun_listesi")
    fi
    ana_menu
}

# Ürün Güncelleme fonksiyonu
urun_guncelle() {
    yetki_kontrol "Ürün Güncelleme" 
    
    urun_adi=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürünün adını girin:")
    
    if [ -z "$urun_adi" ]; then
        zenity --error --title="Hata" --text="Lütfen bir ürün adı girin!"
        urun_guncelle
    else
        # Ürün adıyla ilgili ürün satırını bulma
        urun_satiri=$(grep -i "^.*,$urun_adi," "$DEPO_FILE")
        
        if [ -z "$urun_satiri" ]; then
            zenity --error --title="Hata" --text="Ürün bulunamadı!"
        else
            urun_numarasi=$(echo "$urun_satiri" | cut -d',' -f1)
            stok_miktari=$(echo "$urun_satiri" | cut -d',' -f3)
            birim_fiyati=$(echo "$urun_satiri" | cut -d',' -f4)

            # Kullanıcıdan güncellenecek değerleri alma
            yeni_stok_miktari=$(zenity --entry --title="Stok Güncelle" --text="Eski stok miktarı: $stok_miktari\nYeni stok miktarını girin:" --entry-text="$stok_miktari")
            yeni_birim_fiyati=$(zenity --entry --title="Fiyat Güncelle" --text="Eski birim fiyatı: $birim_fiyati\nYeni birim fiyatını girin:" --entry-text="$birim_fiyati")
            
            # Yeni değerler dosyaya yazılacak
            sed -i "s/^$urun_numarasi,$urun_adi,$stok_miktari,$birim_fiyati$/$urun_numarasi,$urun_adi,$yeni_stok_miktari,$yeni_birim_fiyati/" "$DEPO_FILE"
            zenity --info --title="Başarılı" --text="Ürün başarıyla güncellendi!"
        fi
    fi
    ana_menu
}

# Ürün Silme fonksiyonu
urun_sil() {
    yetki_kontrol "Ürün Silme" 
    
    urun_adi=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürünün adını girin:")
    
    if [ -z "$urun_adi" ]; then
        zenity --error --title="Hata" --text="Lütfen bir ürün adı girin!"
        urun_sil
    else
        # Ürün adıyla ilgili ürün satırını bulma
        urun_satiri=$(grep -i "^.*,$urun_adi," "$DEPO_FILE")
        
        if [ -z "$urun_satiri" ]; then
            zenity --error --title="Hata" --text="Ürün bulunamadı!"
        else
            # Ürünü dosyadan silme
            sed -i "/^.*,$urun_adi,/d" "$DEPO_FILE"
            zenity --info --title="Başarılı" --text="Ürün başarıyla silindi!"
        fi
    fi
    ana_menu
}
rapor_al() {
    secim=$(zenity --list --title="Rapor Al" \
        --column="Rapor Türü" "Stokta Azalan Ürünler" "En Yüksek Stok Miktarına Sahip Ürünler" \
        --height=200 --width=400)
    
    case $secim in
        "Stokta Azalan Ürünler") stokta_azalan_urunler ;;
        "En Yüksek Stok Miktarına Sahip Ürünler") en_yuksek_stoklu_urunler ;;
        *) ana_menu ;;
    esac
}

# Stokta azalan ürünler raporu
stokta_azalan_urunler() {
    esik_deger=$(zenity --entry --title="Stokta Azalan Ürünler" --text="Lütfen eşik değeri girin:")
    
    if [[ ! "$esik_deger" =~ ^[0-9]+$ ]]; then
        zenity --error --title="Hata" --text="Eşik değeri geçerli bir sayı olmalıdır!"
        stokta_azalan_urunler
    else
        azalan_urunler=$(awk -F',' -v esik="$esik_deger" '$3 < esik {print $0}' "$DEPO_FILE")
        
        if [ -z "$azalan_urunler" ]; then
            zenity --info --title="Stokta Azalan Ürünler" --text="Eşik değerden düşük stoklu ürün bulunmamaktadır."
        else
            zenity --text-info --title="Stokta Azalan Ürünler" --width=600 --height=400 --filename=<(echo "$azalan_urunler")
        fi
    fi
    ana_menu
}

# En yüksek stok miktarına sahip ürünler raporu
en_yuksek_stoklu_urunler() {
    esik_deger=$(zenity --entry --title="En Yüksek Stok Miktarına Sahip Ürünler" --text="Lütfen eşik değeri girin:")
    
    if [[ ! "$esik_deger" =~ ^[0-9]+$ ]]; then
        zenity --error --title="Hata" --text="Eşik değeri geçerli bir sayı olmalıdır!"
        en_yuksek_stoklu_urunler
    else
        yuksek_stoklu_urunler=$(awk -F',' -v esik="$esik_deger" '$3 > esik {print $0}' "$DEPO_FILE")
        
        if [ -z "$yuksek_stoklu_urunler" ]; then
            zenity --info --title="En Yüksek Stok Miktarına Sahip Ürünler" --text="Eşik değerden yüksek stoklu ürün bulunmamaktadır."
        else
            zenity --text-info --title="En Yüksek Stok Miktarına Sahip Ürünler" --width=600 --height=400 --filename=<(echo "$yuksek_stoklu_urunler")
        fi
    fi
    ana_menu
}

# Ana Menü fonksiyonu
ana_menu() {
    secim=$(zenity --list --title="Ana Menü" \
        --column="İşlem" "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil" "Rapor Al" "Kullanıcı Yönetimi" \
        "Program Yönetimi" "Çıkış" \
        --height=400 --width=600)

    case $secim in
        "Ürün Ekle") urun_ekle ;;
        "Ürün Listele") urun_listele ;;
        "Ürün Güncelle") urun_guncelle ;;
        "Ürün Sil") urun_sil ;;
        "Rapor Al") rapor_al ;;
        "Kullanıcı Yönetimi") kullanici_yonetimi ;;
        "Program Yönetimi") program_yonetimi ;;
        "Çıkış") exit ;;
        *) exit ;;
    esac
}

# Ürün Ekleme fonksiyonu
urun_ekle() {
    yetki_kontrol "Ürün Ekleme" 
   
    # Ürün numarasını belirleme: Dosyadaki mevcut ürün sayısına göre artarak atanır.
    # İlk ürün için 1'den başlayacak şekilde ürün numarasını alıyoruz.
    if [ -f "$DEPO_FILE" ] && [ -s "$DEPO_FILE" ]; then
        urun_sayisi=$(wc -l < "$DEPO_FILE")
        urun_numarasi=$((urun_sayisi + 1))
    else
        urun_numarasi=1
    fi

    # Ürün bilgilerini Zenity formu ile almak
    form_girdi=$(zenity --forms --title="Ürün Ekle" \
        --text="Yeni ürün bilgilerini girin" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı")

    # Formdan gelen veriyi ayırma (Ürün adı, stok miktarı, birim fiyatı)
    urun_adi=$(echo "$form_girdi" | cut -d'|' -f1)
    stok_miktari=$(echo "$form_girdi" | cut -d'|' -f2)
    birim_fiyati=$(echo "$form_girdi" | cut -d'|' -f3)

    # Gerekli alanların boş olup olmadığını kontrol etme
    if [ -z "$urun_adi" ] || [ -z "$stok_miktari" ] || [ -z "$birim_fiyati" ]; then
        zenity --error --title="Hata" --text="Lütfen tüm alanları doldurun!"
        urun_ekle
    else
        # Aynı isimde ürün olup olmadığını kontrol et
        mevcut_urun=$(grep -i ",$urun_adi," "$DEPO_FILE")
        if [ -n "$mevcut_urun" ]; then
            # Hata mesajı ve log kaydı
            hata_mesaji="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
            zenity --error --title="Hata" --text="$hata_mesaji"
            echo "$(date),HATA,Ürün Ekleme,$urun_adi,$hata_mesaji" >> "$LOG_FILE"
            urun_ekle
        else
            # Verileri CSV dosyasına yazma
            echo "$urun_numarasi,$urun_adi,$stok_miktari,$birim_fiyati" >> "$DEPO_FILE"
            zenity --info --title="Başarılı" --text="Ürün başarıyla eklendi!"
        fi
    fi
    ana_menu
}
yetki_kontrol() { 
    islem=$1
    if [[ "$KULLANICI_ROL" != "admin" ]]; then
        zenity --error --title="Yetki Hatası" --text="Bu işlem için yetkiniz yok: $islem"
        ana_menu  # Yetki yoksa doğrudan ana menüye dön
    fi
}


# Programın başlatılması
giris_ekrani() {
    secim=$(zenity --list --title="Giriş Yap veya Kullanıcı Oluştur" \
        --column="Seçenekler" "Giriş Yap" "Kullanıcı Oluştur" \
        --height=200 --width=400)

    case $secim in
        "Giriş Yap") kullanici_girisi ;;
        "Kullanıcı Oluştur") kullanici_olustur;;
        *) exit ;;
    esac
}

# Giriş yapma fonksiyonu
kullanici_girisi() {
    giris_bilgisi=$(zenity --forms --title="Giriş Yap" \
        --text="Kullanıcı adı ve şifrenizi girin" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Şifre")

    kullanici_adi=$(echo "$giris_bilgisi" | cut -d'|' -f1)
    sifre=$(echo "$giris_bilgisi" | cut -d'|' -f2)

    if [ -z "$kullanici_adi" ] || [ -z "$sifre" ]; then
        zenity --error --title="Hata" --text="Tüm alanları doldurun!"
        kullanici_girisi
    else
        # Kullanıcı doğrulama
        satir=$(grep -i "^$kullanici_adi,$sifre," "$KULLANICI_FILE")

        if [ -z "$satir" ]; then
            zenity --error --title="Hata" --text="Kullanıcı adı veya şifre hatalı!"
            kullanici_girisi
        else
            # Kullanıcı rolünü belirle
            KULLANICI_ROL=$(echo "$satir" | cut -d',' -f3)
            zenity --info --title="Başarılı" --text="Hoş geldiniz, $kullanici_adi!"
            ana_menu
        fi
    fi
}
kullanici_olustur() {
    # Kullanıcı bilgilerini form ile al
    form_girdi=$(zenity --forms --title="Yeni Kullanıcı Oluştur" \
        --text="Yeni kullanıcı bilgilerini girin" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Şifre")

    # Kullanıcı adı ve şifreyi ayrıştır
    kullanici_adi=$(echo "$form_girdi" | cut -d'|' -f1)
    sifre=$(echo "$form_girdi" | cut -d'|' -f2)

    # Girdilerin eksik olup olmadığını kontrol et
    if [ -z "$kullanici_adi" ] || [ -z "$sifre" ]; then
        zenity --error --title="Hata" --text="Tüm alanları doldurun!"
        kullanici_olustur
    elif grep -qi "^$kullanici_adi," "$KULLANICI_FILE"; then
        # Aynı isimde bir kullanıcı varsa hata mesajı göster
        zenity --error --title="Hata" --text="Bu kullanıcı adı zaten mevcut!"
        kullanici_olustur
    else
        # Yeni kullanıcıyı 'user' rolüyle dosyaya ekle
        echo "$kullanici_adi,$sifre,user" >> "$KULLANICI_FILE"
        zenity --info --title="Başarılı" --text="Kullanıcı başarıyla oluşturuldu!"
    fi
    giris_ekrani
}

kullanici_yonetimi() {
    secim=$(zenity --list --title="Kullanıcı Yönetimi" \
        --column="İşlem" "Yeni Kullanıcı Ekle" "Kullanıcıları Listele" "Kullanıcı Güncelle" "Kullanıcı Sil" \
        --height=300 --width=400)

    case $secim in
        "Yeni Kullanıcı Ekle") kullanici_ekle ;;
        "Kullanıcıları Listele") kullanici_listele ;;
        "Kullanıcı Güncelle") kullanici_guncelle ;;
        "Kullanıcı Sil") kullanici_sil ;;
        *) ana_menu ;;
    esac
}
kullanici_ekle() {
    yetki_kontrol "Kullanıcı Ekleme" || return

    form_girdi=$(zenity --forms --title="Yeni Kullanıcı Ekle" \
        --text="Yeni kullanıcı bilgilerini girin" \
        --add-entry="Kullanıcı Adı" \
        --add-password="Şifre" \
        --add-combo="Rol" --combo-values="admin|user")

    kullanici_adi=$(echo "$form_girdi" | cut -d'|' -f1)
    sifre=$(echo "$form_girdi" | cut -d'|' -f2)
    rol=$(echo "$form_girdi" | cut -d'|' -f3)

    if [ -z "$kullanici_adi" ] || [ -z "$sifre" ] || [ -z "$rol" ]; then
        zenity --error --title="Hata" --text="Tüm alanları doldurun!"
        kullanici_ekle
    elif grep -qi "^$kullanici_adi," "$KULLANICI_FILE"; then
        zenity --error --title="Hata" --text="Bu kullanıcı adı zaten mevcut!"
    else
        echo "$kullanici_adi,$sifre,$rol" >> "$KULLANICI_FILE"
        zenity --info --title="Başarılı" --text="Kullanıcı başarıyla eklendi!"
    fi
    ana_menu
}
kullanici_listele() {
    yetki_kontrol "Kullanıcı Listeleme" || return

    if [ ! -s "$KULLANICI_FILE" ]; then
        zenity --info --title="Bilgi" --text="Kayıtlı kullanıcı yok."
    else
        zenity --text-info --title="Kullanıcı Listesi" --width=600 --height=400 --filename="$KULLANICI_FILE"
    fi
    ana_menu
}
kullanici_guncelle() {
    yetki_kontrol "Kullanıcı Güncelleme" || return

    kullanici_adi=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı adını girin:")

    if [ -z "$kullanici_adi" ] || ! grep -qi "^$kullanici_adi," "$KULLANICI_FILE"; then
        zenity --error --title="Hata" --text="Kullanıcı bulunamadı!"
    else
        form_girdi=$(zenity --forms --title="Kullanıcı Güncelle" \
            --text="Yeni bilgileri girin (Boş bırakılan alanlar değişmez):" \
            --add-password="Yeni Şifre" \
            --add-combo="Yeni Rol" --combo-values="admin|user")

        yeni_sifre=$(echo "$form_girdi" | cut -d'|' -f1)
        yeni_rol=$(echo "$form_girdi" | cut -d'|' -f2)

        eski_kayit=$(grep -i "^$kullanici_adi," "$KULLANICI_FILE")
        yeni_kayit=$(echo "$eski_kayit" | awk -F',' -v sifre="$yeni_sifre" -v rol="$yeni_rol" \
            '{if(sifre!="") $2=sifre; if(rol!="") $3=rol; print $1","$2","$3}')
        
        sed -i "/^$kullanici_adi,/d" "$KULLANICI_FILE"
        echo "$yeni_kayit" >> "$KULLANICI_FILE"

        zenity --info --title="Başarılı" --text="Kullanıcı başarıyla güncellendi!"
    fi
    ana_menu
}

kullanici_sil() {
    yetki_kontrol "Kullanıcı Silme" || return

    kullanici_adi=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adını girin:")

    if [ -z "$kullanici_adi" ] || ! grep -qi "^$kullanici_adi," "$KULLANICI_FILE"; then
        zenity --error --title="Hata" --text="Kullanıcı bulunamadı!"
    else
        sed -i "/^$kullanici_adi,/d" "$KULLANICI_FILE"
        zenity --info --title="Başarılı" --text="Kullanıcı başarıyla silindi!"
    fi
    ana_menu
}
program_yonetimi() {
    secim=$(zenity --list --title="Program Yönetimi" \
        --text="Bir işlem seçin:" \
        --column="No" --column="İşlem" \
        1 "Diskteki Alanı Göster" \
        2 "Diske Yedekle" \
        3 "Hata Kayıtlarını Göster" \
        --height=300 --width=400)

    case $secim in
        1) diskteki_alani_goster ;;
        2) diske_yedekle ;;
        3) hata_kayitlarini_goster ;;
        *) ana_menu ;;  # Geçerli bir seçim yoksa ana menüye dön
    esac
}

# 1. Diskteki Alanı Göster
diskteki_alani_goster() {
    dosyalar=("$(basename "$0")" "depo.csv" "kullanici.txt" "log.csv")
    rapor=""
    toplam_boyut=0

    for dosya in "${dosyalar[@]}"; do
        if [ -f "$dosya" ]; then
            boyut=$(du -b "$dosya" | cut -f1)
            toplam_boyut=$((toplam_boyut + boyut))
            rapor+="$dosya: $boyut byte\n"
        else
            rapor+="$dosya: Dosya bulunamadı\n"
        fi
    done
    rapor+="\nToplam Boyut: $toplam_boyut byte"

    zenity --info --title="Diskteki Alan" --text="$rapor"
    ana_menu
}

# 2. Diske Yedekle
diske_yedekle() {
    yedek_klasoru="yedek"
    mkdir -p "$yedek_klasoru"

    cp depo.csv "$yedek_klasoru/" 2>/dev/null || echo "depo.csv bulunamadı."
    cp kullanicilar.txt "$yedek_klasoru/" 2>/dev/null || echo "kullanicilar.txt bulunamadı."

    zenity --info --title="Yedekleme Tamamlandı" \
        --text="Yedekleme işlemi başarıyla tamamlandı. Yedekler '$yedek_klasoru/' klasöründe."
    ana_menu
}

# 3. Hata Kayıtlarını Göster
hata_kayitlarini_goster() {
    if [ -f "log.csv" ]; then
        zenity --text-info --title="Hata Kayıtları" --filename="log.csv" --height=500 --width=600
    else
        zenity --error --title="Hata" --text="Hata kayıt dosyası (log.csv) bulunamadı!"
    fi
    ana_menu
}



# Programı başlat
giris_ekrani

