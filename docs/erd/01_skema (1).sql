-- 01_skema.sql : skema relasional Sistem Manajemen Event Pariwisata dan Evaluasi Dampak
-- Kelompok 1 Create Analysis, PABW SIF302 (P20). MySQL 8.x. Jalankan pada basis data kosong.
CREATE DATABASE IF NOT EXISTS event_wisata DEFAULT CHARACTER SET utf8mb4;
USE event_wisata;

-- 1. pengguna (semua peran: penyelenggara, staf, kepala, wisatawan)
CREATE TABLE pengguna (
  id_pengguna     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama            VARCHAR(100) NOT NULL,
  email           VARCHAR(100) NOT NULL,
  kata_sandi_hash VARCHAR(255) NOT NULL,
  peran           VARCHAR(20)  NOT NULL,
  PRIMARY KEY (id_pengguna),
  CONSTRAINT uq_pengguna_email UNIQUE (email),
  CONSTRAINT chk_pengguna_peran CHECK (peran IN ('penyelenggara','staf','kepala','wisatawan'))
) ENGINE=InnoDB;

-- 2. event (pengguna 1:N event)
CREATE TABLE event (
  id_event         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_event       VARCHAR(150) NOT NULL,
  deskripsi        TEXT NULL,
  lokasi           VARCHAR(150) NOT NULL,
  tanggal_mulai    DATE NOT NULL,
  tanggal_selesai  DATE NOT NULL,
  harga_tiket      INT UNSIGNED NOT NULL DEFAULT 0,
  id_penyelenggara INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_event),
  CONSTRAINT chk_event_tanggal CHECK (tanggal_selesai >= tanggal_mulai),
  CONSTRAINT fk_event_penyelenggara
    FOREIGN KEY (id_penyelenggara) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. izin_event (event 1:N izin_event; pengguna 1:N izin_event sebagai pemroses)
CREATE TABLE izin_event (
  id_izin           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_event          INT UNSIGNED NOT NULL,
  id_pemroses       INT UNSIGNED NULL,               -- NULL = belum diproses
  tanggal_pengajuan DATE NOT NULL,
  status            VARCHAR(15) NOT NULL DEFAULT 'diajukan',
  catatan           TEXT NULL,
  tanggal_diproses  DATE NULL,
  PRIMARY KEY (id_izin),
  CONSTRAINT chk_izin_status CHECK (status IN ('diajukan','disetujui','ditolak')),
  CONSTRAINT chk_izin_tanggal CHECK (tanggal_diproses IS NULL OR tanggal_diproses >= tanggal_pengajuan),
  CONSTRAINT fk_izin_event
    FOREIGN KEY (id_event) REFERENCES event(id_event)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_izin_pemroses
    FOREIGN KEY (id_pemroses) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. kerja_sama_tiket
CREATE TABLE kerja_sama_tiket (
  id_kerja_sama         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_event              INT UNSIGNED NOT NULL,
  id_pemroses           INT UNSIGNED NULL,
  jumlah_tiket_diajukan INT UNSIGNED NOT NULL,
  keterangan            TEXT NULL,
  tanggal_pengajuan     DATE NOT NULL,
  status                VARCHAR(15) NOT NULL DEFAULT 'diajukan',
  tanggal_diproses      DATE NULL,
  PRIMARY KEY (id_kerja_sama),
  CONSTRAINT chk_kerja_jumlah CHECK (jumlah_tiket_diajukan > 0),
  CONSTRAINT chk_kerja_status CHECK (status IN ('diajukan','disetujui','ditolak')),
  CONSTRAINT fk_kerja_event
    FOREIGN KEY (id_event) REFERENCES event(id_event)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kerja_pemroses
    FOREIGN KEY (id_pemroses) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. tiket (satu baris = satu pesanan dengan satu kode unik)
CREATE TABLE tiket (
  id_tiket      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode_tiket    VARCHAR(30) NOT NULL,
  id_event      INT UNSIGNED NOT NULL,
  id_pemesan    INT UNSIGNED NOT NULL,
  jumlah        INT UNSIGNED NOT NULL,
  harga_satuan  INT UNSIGNED NOT NULL,                 -- harga saat pesan (catatan historis)
  tanggal_pesan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_tiket),
  CONSTRAINT uq_tiket_kode UNIQUE (kode_tiket),
  CONSTRAINT chk_tiket_jumlah CHECK (jumlah > 0),
  CONSTRAINT fk_tiket_event
    FOREIGN KEY (id_event) REFERENCES event(id_event)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_pemesan
    FOREIGN KEY (id_pemesan) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. data_dampak
CREATE TABLE data_dampak (
  id_dampak             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_event              INT UNSIGNED NOT NULL,
  id_pencatat           INT UNSIGNED NOT NULL,
  tanggal_catat         DATE NOT NULL,
  jumlah_pengunjung     INT UNSIGNED NOT NULL,
  lama_tinggal_hari     DECIMAL(5,2) NOT NULL,
  pengeluaran_rata_rata INT UNSIGNED NOT NULL,         -- Rupiah
  persepsi_warga_persen DECIMAL(5,2) NULL,
  sumber_data           VARCHAR(50) NOT NULL DEFAULT 'input staf',
  PRIMARY KEY (id_dampak),
  CONSTRAINT chk_dampak_lama CHECK (lama_tinggal_hari >= 0),
  CONSTRAINT chk_dampak_persepsi CHECK (persepsi_warga_persen BETWEEN 0 AND 100),
  CONSTRAINT fk_dampak_event
    FOREIGN KEY (id_event) REFERENCES event(id_event)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_dampak_pencatat
    FOREIGN KEY (id_pencatat) REFERENCES pengguna(id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
