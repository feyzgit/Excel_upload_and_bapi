# Excel_upload_and_bapi

Program adı: BMC POWER TIMESHEET İSTATİSTİKSEL GÖSTERGE PROGRAMI

“PYP öğesi” ve “Yüzde” 	olarak iki kolondan oluşan bir excelin yükleneceği program yazılacaktır,
Dosya yolu ve Dönem/Yıl olan bir seçim ekranı olacak  
Örnek Excel:
  PYP	             Yüzde
 BP.010.01.01.12.06	1,71
 BP.010.01.03.00.06	9,83
 BP.010.01.01.14.06	2,56
 BP.010.01.05.01.06	23,5
 BP.010.01.04.01.06	5,98
 BP.010.01.05.02.06	2,14
 BP.010.01.05.05.06	31,62
 BP.010.01.05.03.06	5,56
 BP.010.01.01.00.06	11,54
 BP.010.01.01.00.06	1,71
 BP.010.01.01.07.06	3,85

 
BAPI_ACC_STAT_KEY_FIG_POST bapisinde
Username: Kayıt atan kullanıcı 
CO_AREA: BM00
DOC_HDR_TX:    “BMC POWER ‘Çalıştırılan Ay/Yıl değeri’ Timesheet girişleri”
POSTGDATE: Çalıştırılan ay/yıl’ın son günü (örn, 07/22 ise 31.07.2022) 

Item olarak
REC_WBS_EL: excelde girilen PYP öğeleri, 
STAT_QTY : Pyp öğelerinin yanında yazan ,% değerleri
STATKEYFIG: TIME

Oluşan belge numarası bir log tablosunda çalıştırılan dönem/ yıl bilgisi ile birlikte tutulmalıdır.

Kullanıcı aynı yıl ve aynı ay için çalıştırma yaparsa hata mesajı verilmelidir.

Uyarı mesajı: “ Bu dönem için önceden istatistiksel gösterge belgeleri kaydedildi!!!”

Bunun için Dönem/yıl ve belge numarasını tutan bir log tablosu yapılmalıdır
