-- Skema basis data: Sistem Manajemen Event Pariwisata dan Evaluasi Dampak
-- Kelompok 1 Create Analysis (PABW SIF302). DRAFT hasil P19, perlu ditinjau kelompok.
-- Dialek: SQLite (rencana teknis P17). Untuk MySQL: ganti INTEGER PRIMARY KEY AUTOINCREMENT
-- dengan INT AUTO_INCREMENT PRIMARY KEY.
PRAGMA foreign_keys = ON;

CREATE TABLE pengguna (
  id_pengguna     INTEGER PRIMARY KEY AUTOINCREMENT,
  nama            TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE,
  kata_sandi_hash TEXT NOT NULL,
  peran           TEXT NOT NULL CHECK (peran IN ('penyelenggara','staf','kepala','wisatawan'))
);

CREATE TABLE event (
  id_event         INTEGER PRIMARY KEY AUTOINCREMENT,
  nama_event       TEXT NOT NULL,
  deskripsi        TEXT,
  lokasi           TEXT NOT NULL,
  tanggal_mulai    DATE NOT NULL,
  tanggal_selesai  DATE NOT NULL,
  harga_tiket      INTEGER NOT NULL DEFAULT 0 CHECK (harga_tiket >= 0),
  id_penyelenggara INTEGER NOT NULL REFERENCES pengguna(id_pengguna),
  CHECK (tanggal_selesai >= tanggal_mulai)
);

CREATE TABLE izin_event (
  id_izin           INTEGER PRIMARY KEY AUTOINCREMENT,
  id_event          INTEGER NOT NULL REFERENCES event(id_event),
  id_pemroses       INTEGER REFERENCES pengguna(id_pengguna),  -- NULL = belum diproses
  tanggal_pengajuan DATE NOT NULL,
  status            TEXT NOT NULL DEFAULT 'diajukan' CHECK (status IN ('diajukan','disetujui','ditolak')),
  catatan           TEXT,
  tanggal_diproses  DATE
);

CREATE TABLE kerja_sama_tiket (
  id_kerja_sama         INTEGER PRIMARY KEY AUTOINCREMENT,
  id_event              INTEGER NOT NULL REFERENCES event(id_event),
  id_pemroses           INTEGER REFERENCES pengguna(id_pengguna),
  jumlah_tiket_diajukan INTEGER NOT NULL CHECK (jumlah_tiket_diajukan > 0),
  keterangan            TEXT,
  tanggal_pengajuan     DATE NOT NULL,
  status                TEXT NOT NULL DEFAULT 'diajukan' CHECK (status IN ('diajukan','disetujui','ditolak')),
  tanggal_diproses      DATE
);

CREATE TABLE tiket (  -- satu baris = satu pesanan (satu kode unik, boleh berisi beberapa tiket)
  id_tiket      INTEGER PRIMARY KEY AUTOINCREMENT,
  kode_tiket    TEXT NOT NULL UNIQUE,
  id_event      INTEGER NOT NULL REFERENCES event(id_event),
  id_pemesan    INTEGER NOT NULL REFERENCES pengguna(id_pengguna),
  jumlah        INTEGER NOT NULL CHECK (jumlah > 0),
  harga_satuan  INTEGER NOT NULL CHECK (harga_satuan >= 0),  -- harga saat pesan, bukan total turunan
  tanggal_pesan DATETIME NOT NULL
);

CREATE TABLE data_dampak (
  id_dampak             INTEGER PRIMARY KEY AUTOINCREMENT,
  id_event              INTEGER NOT NULL REFERENCES event(id_event),
  id_pencatat           INTEGER NOT NULL REFERENCES pengguna(id_pengguna),
  tanggal_catat         DATE NOT NULL,
  jumlah_pengunjung     INTEGER NOT NULL CHECK (jumlah_pengunjung >= 0),
  lama_tinggal_hari     REAL    NOT NULL CHECK (lama_tinggal_hari >= 0),
  pengeluaran_rata_rata INTEGER NOT NULL CHECK (pengeluaran_rata_rata >= 0),  -- Rupiah
  persepsi_warga_persen REAL    CHECK (persepsi_warga_persen BETWEEN 0 AND 100),
  sumber_data           TEXT NOT NULL DEFAULT 'input staf'
);

CREATE INDEX idx_izin_event   ON izin_event(id_event);
CREATE INDEX idx_kerja_event  ON kerja_sama_tiket(id_event);
CREATE INDEX idx_tiket_event  ON tiket(id_event);
CREATE INDEX idx_dampak_event ON data_dampak(id_event);
