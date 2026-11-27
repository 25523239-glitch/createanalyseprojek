# Skema Relasional Proyek

Sistem Manajemen Event Pariwisata dan Evaluasi Dampak, Kelompok 1 Create Analysis (PABW SIF302, P20).
Notasi: nama_tabel(PK, kolom, FK). Primary key diberi <ins>garis bawah</ins>, foreign key dicetak *miring*.
Berpadanan dengan `erd_proyek.png` dan `01_skema.sql` di folder ini.

| No | Skema | FK |
|---|---|---|
| 1 | pengguna(<ins>id_pengguna</ins>, nama, email, kata_sandi_hash, peran) | tidak ada |
| 2 | event(<ins>id_event</ins>, nama_event, deskripsi, lokasi, tanggal_mulai, tanggal_selesai, harga_tiket, *id_penyelenggara*) | id_penyelenggara → pengguna(id_pengguna) |
| 3 | izin_event(<ins>id_izin</ins>, *id_event*, *id_pemroses*, tanggal_pengajuan, status, catatan, tanggal_diproses) | id_event → event(id_event); id_pemroses → pengguna(id_pengguna), boleh NULL |
| 4 | kerja_sama_tiket(<ins>id_kerja_sama</ins>, *id_event*, *id_pemroses*, jumlah_tiket_diajukan, keterangan, tanggal_pengajuan, status, tanggal_diproses) | id_event → event(id_event); id_pemroses → pengguna(id_pengguna), boleh NULL |
| 5 | tiket(<ins>id_tiket</ins>, kode_tiket, *id_event*, *id_pemesan*, jumlah, harga_satuan, tanggal_pesan) | id_event → event(id_event); id_pemesan → pengguna(id_pengguna) |
| 6 | data_dampak(<ins>id_dampak</ins>, *id_event*, *id_pencatat*, tanggal_catat, jumlah_pengunjung, lama_tinggal_hari, pengeluaran_rata_rata, persepsi_warga_persen, sumber_data) | id_event → event(id_event); id_pencatat → pengguna(id_pengguna) |

## Pemetaan aturan

| Bagian ERD | Aturan | Hasil |
|---|---|---|
| Setiap entitas (6 buah) | 1: entitas reguler menjadi tabel | tabel 1 sampai 6, PK id buatan |
| pengguna menyelenggarakan event (1:N) | 4: FK di sisi banyak | event.id_penyelenggara |
| event diajukan izin (1:N) | 4 | izin_event.id_event |
| pengguna memproses izin (1:N, parsial) | 4 | izin_event.id_pemroses (boleh NULL) |
| event diajukan kerja sama tiket (1:N) | 4 | kerja_sama_tiket.id_event |
| pengguna memproses kerja sama (1:N, parsial) | 4 | kerja_sama_tiket.id_pemroses (boleh NULL) |
| event dipesan tiketnya (1:N) | 4 | tiket.id_event |
| pengguna memesan tiket (1:N) | 4 | tiket.id_pemesan |
| event dicatat dampaknya (1:N) | 4 | data_dampak.id_event |
| pengguna mencatat dampak (1:N) | 4 | data_dampak.id_pencatat |

Aturan 2 (entitas lemah), 3 (1:1), 5 (M:N), 6 (multinilai), dan 7 (relasi n-ary) tidak dipakai karena ERD proyek tidak memuat hal tersebut.

## Kendala yang dibuktikan (lihat `02_uji_kendala.sql`)

UNIQUE kode_tiket, CHECK peran, CHECK tanggal_selesai >= tanggal_mulai, FOREIGN KEY tiket.id_event, NOT NULL event.nama_event.
