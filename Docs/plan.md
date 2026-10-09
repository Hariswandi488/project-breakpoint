# Project Breakpoint — Development Plan (v2)

> Versi ini dibuat supaya **bisa langsung dikerjakan**: setiap tahap punya
> langkah jelas, tes yang jelas, dan tanda "udah selesai" yang jelas.
> Bukan versi ringkas — justru lebih detail biar nggak bingung harus mulai dari mana.

---

## 0. Cara pakai dokumen ini

**Alur kerja untuk SETIAP tahap (ulangi terus):**

```
1. BACA   → baca tahap aktif sampai habis (jangan loncat)
2. PAHAMI → baca bagian "Konsep yang dipelajari"
3. BUAT   → ikuti "Langkah kerja" satu per satu
4. TES    → jalankan (F5), cocokkan dengan "Hasil yang harus terlihat"
5. CENTANG→ semua kotak "Selesai jika" harus ✅
6. SIMPAN → git commit + catat di Log (bagian 12)
7. LANJUT → baru buka tahap berikutnya
```

**Aturan emas:**
1. Satu tahap dalam satu waktu. Tahap berikutnya **terkunci** sampai tahap aktif lolos tes.
2. Kalau error, selesaikan **error pertama** dulu. Error di bawahnya sering cuma efek domino.
3. Jangan tambah fitur baru di tengah tahap. Tulis idenya di bagian "Ide nanti" (bagian 13).
4. Selalu jalankan game setelah perubahan kecil. Jangan nulis 200 baris baru baru dites.
5. Kalau sudah stuck lebih dari 30 menit, pakai template "Prompt untuk Claude" (bagian 10).

**Dua level di tiap tahap:**
- 🟢 **Wajib** → harus selesai untuk MVP.
- 🔵 **Naik level (opsional)** → hanya dikerjakan **setelah** tahap itu lolos tes dan sudah di-commit. Ini bagian "advance" buat belajar lebih dalam. Boleh dilewati tanpa merusak MVP.

---

## 1. Tujuan proyek

Membuat game 3D third-person action sederhana di Godot. Tujuan utama adalah
**menyelesaikan game yang bisa dimainkan dari awal sampai akhir**, sambil
belajar workflow game development dari mekanik sampai aset.

Prioritas:
1. Bisa dimainkan dari awal sampai selesai.
2. Mekanik utama bekerja konsisten.
3. Kode cukup rapi agar mudah dikembangkan.
4. Aset dan visual dipoles **setelah** gameplay berfungsi.

---

## 2. Konsep MVP

Pemain masuk ke satu arena dan mengalahkan semua musuh untuk menyelesaikan level.

### Fitur wajib
- Gerakan third-person: jalan, lari, lompat (kalau dibutuhkan).
- Kamera third-person yang mengikuti pemain.
- Satu serangan melee.
- Health dan damage untuk pemain dan musuh.
- Satu jenis musuh dengan AI sederhana: mendekati pemain lalu menyerang.
- Kondisi menang dan kalah.
- Tombol restart.
- Satu arena kecil dengan awal dan akhir yang jelas.

### Belum termasuk MVP
- Skill tree, inventaris, crafting, banyak senjata.
- Open world, cerita panjang, quest.
- Multiplayer.
- Banyak tipe musuh, boss kompleks.
- Kombo rumit dan animasi final.

---

## 3. Peta besar (lihat ini kalau lupa lagi di mana)

```
[0 Setup] → [1 Gerak+Kamera] → [2 Combat Player] → [3 Musuh]
														↓
[7 Finishing] ← [6 Aset+Animasi] ← [5 Greybox+Tes] ← [4 Satu Putaran Game]
```

Titik penting:
- **Setelah Tahap 4** → kamu sudah punya **game yang bisa dimainkan** (jelek tapi jadi). Ini milestone terbesar.
- **Tahap 5-7** hanya memoles dan merapikan, bukan menambah mekanik.

Estimasi (kasar, tergantung waktu luang): tiap tahap 1–3 sesi kerja. Tahap 6 biasanya paling lama karena Blender.

---

## 4. Kamus singkat Godot (biar nggak bingung istilah)

| Istilah | Artinya (versi gampang) |
|---|---|
| **Node** | Satu "blok bangunan". Contoh: mesh, kamera, collision. |
| **Scene** | Kumpulan node yang disimpan jadi satu file (`.tscn`). Bisa dipakai ulang, misalnya `player.tscn`. |
| **Script** | File kode (`.gd`) yang ditempel ke node. |
| **CharacterBody3D** | Node untuk karakter yang digerakkan lewat kode (player & musuh). |
| **StaticBody3D** | Benda diam yang bisa ditabrak (lantai, tembok). |
| **Area3D** | Zona tak terlihat yang mendeteksi benda masuk/keluar. Dipakai untuk **hitbox**. |
| **CollisionShape3D** | Bentuk fisik untuk collision. Wajib ada di dalam body/area. |
| **Signal** | "Pengumuman": node A teriak "aku mati!", node B yang peduli langsung merespons. Tanpa saling mengenal. |
| **@export** | Variabel yang bisa diubah dari Inspector tanpa buka kode. Bagus untuk tuning. |
| **@onready** | Ambil referensi node setelah scene siap. |
| **Group** | Label untuk node, misalnya `"enemies"`. Berguna untuk menghitung musuh tersisa. |
| **Autoload** | Script global yang selalu hidup (misal `GameManager`). Pakai seperlunya. |
| **Hitbox** | Area yang **memberi** damage (pedang). |
| **Hurtbox** | Area yang **menerima** damage (badan). |
| **State machine** | Cara mengatur "lagi ngapain": `idle`, `move`, `attack`, dst. Hanya satu state aktif pada satu waktu. |
| **Physics process** | `_physics_process(delta)` jalan tiap frame fisika. Untuk gerakan & combat. |

---

## 5. Struktur folder

```text
res://
├── scenes/
│   ├── main/        → main.tscn, menu
│   ├── player/      → player.tscn
│   ├── enemies/     → enemy.tscn
│   └── levels/      → arena.tscn
├── scripts/
│   ├── player/      → player.gd
│   ├── combat/      → health_component.gd, (hitbox bila dipisah)
│   ├── enemies/     → enemy.gd
│   ├── ui/          → hud.gd, end_screen.gd
│   └── game/        → game_manager.gd (muncul di Tahap 4)
├── assets/
│   ├── models/  materials/  textures/  animations/  audio/
└── docs/
	└── plan.md
```

Aturan: buat folder baru hanya kalau benar-benar perlu. Jangan bikin arsitektur untuk fitur yang belum ada.

---

## 6. Setup kerja (sekali di awal)

### 6.1 Git (sangat disarankan)
Git = tombol "undo" untuk seluruh proyek. Kalau kode rusak, kamu bisa balik ke versi yang jalan.

```
git init
git add .
git commit -m "Tahap 0: setup awal"
```

Kebiasaan: **commit setiap kali satu tahap lolos tes** (dan boleh lebih sering). Format pesan: `Tahap X: apa yang selesai`.
Opsional: beri tag di akhir milestone, misalnya `git tag v0.4-playable`.

> Godot sudah membuat `.gitignore` otomatis kalau kamu memilih Git saat membuat project. Pastikan folder `.godot/` tidak ikut di-commit.

### 6.2 Versi Godot
Pakai **Godot 4.3 atau lebih baru** (beberapa kode di plan ini memakai `get_gravity()` yang ada sejak 4.3). Catat versi yang kamu pakai di Log.

### 6.3 Tabel Collision Layer (tetapkan dari awal!)
Ini sumber bug nomor satu di game 3D. Pakai tabel ini terus supaya konsisten:

| Layer | Nama | Dipakai oleh |
|---|---|---|
| 1 | `world` | Lantai, tembok |
| 2 | `player` | Body player |
| 3 | `enemy` | Body musuh |
| 4 | `player_attack` | Hitbox serangan player |
| 5 | `enemy_attack` | Hitbox serangan musuh |

Cara baca: **Layer** = "aku ini apa". **Mask** = "aku bisa melihat/menabrak apa".

| Node | Layer | Mask |
|---|---|---|
| Lantai / tembok | 1 | — |
| Player body | 2 | 1 |
| Enemy body | 3 | 1 |
| Player attack hitbox (Area3D) | 4 | 3 |
| Enemy attack hitbox (Area3D) | 5 | 2 |

Beri nama layer di: `Project Settings → Layer Names → 3D Physics`.

### 6.4 Nama Input Map (pakai persis ini)
`Project Settings → Input Map`:

| Action | Tombol |
|---|---|
| `move_forward` | W |
| `move_back` | S |
| `move_left` | A |
| `move_right` | D |
| `sprint` | Shift |
| `jump` | Space |
| `attack` | Klik kiri mouse |
| `restart` | R |
| `pause` / `ui_cancel` | Esc |

---

## 7. Tahap-tahap

### TAHAP 0 — Project setup

**Tujuan:** proyek jalan, ada arena, ada pemain placeholder.

**Konsep yang dipelajari:** scene vs node, cara menjalankan scene, Input Map.

**Struktur scene:**
```text
Main (Node3D)                      ← main.tscn
├── Arena (instance arena.tscn)
└── Player (instance player.tscn)

Arena (Node3D)                     ← arena.tscn
├── Floor (StaticBody3D)
│   ├── MeshInstance3D  (BoxMesh pipih / PlaneMesh)
│   └── CollisionShape3D (BoxShape3D)
├── DirectionalLight3D
└── WorldEnvironment (opsional)

Player (CharacterBody3D)           ← player.tscn
├── MeshInstance3D   (CapsuleMesh)
└── CollisionShape3D (CapsuleShape3D)
```

**Langkah kerja:**
1. 🟢 Buat project Godot 4 baru (renderer Forward+ atau Mobile, bebas). Pilih Git.
2. 🟢 Buat folder sesuai bagian 5.
3. 🟢 Buat `arena.tscn` (lantai besar + cahaya).
4. 🟢 Buat `player.tscn` dari capsule.
5. 🟢 Buat `main.tscn`, masukkan arena dan player. Set sebagai Main Scene.
6. 🟢 Isi Layer Names (6.3) dan Input Map (6.4).
7. 🟢 Simpan `plan.md` ke `docs/`.
8. 🟢 `git commit`.

**Tes:** tekan F5. Kamu melihat lantai dan capsule berdiri di atasnya. Belum bisa gerak itu normal.

**Selesai jika:**
- [ ] Project terbuka tanpa error.
- [ ] Player muncul di arena.
- [ ] Input Map dan Layer Names sudah diisi.
- [ ] Sudah di-commit.

🔵 **Naik level:** pasang `.gitignore` yang rapi dan buat `README.md` kecil berisi cara menjalankan proyek.

---

### TAHAP 1 — Player movement dan kamera

**Tujuan:** player bergerak relatif ke arah kamera, kamera stabil.

**Konsep yang dipelajari:** `_physics_process`, `velocity`, `move_and_slide()`, gravitasi, `Input.get_vector`, kamera dengan SpringArm3D, `delta`.

**Struktur scene player (ubah):**
```text
Player (CharacterBody3D)
├── Visual (Node3D)              ← bagian yang berputar menghadap arah gerak
│   └── MeshInstance3D           (capsule; nanti diganti model Blender)
├── CollisionShape3D
└── CameraPivot (Node3D)         ← diputar kiri-kanan (yaw) oleh mouse
	└── SpringArm3D              ← diputar atas-bawah (pitch), mencegah kamera tembus tembok
		└── Camera3D
```
> Kenapa ada `Visual` terpisah? Supaya yang berputar hanya tampilan, bukan body/collision/kamera. Ini juga memudahkan Tahap 6 saat memasang model.

**Ide inti gerakan (pahami dulu, lalu tulis sendiri / minta Claude):**
```gdscript
func _physics_process(delta):
	# 1. Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Baca input -> arah relatif kamera (hanya yaw, abaikan pitch)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (camera_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()

	# 3. Terapkan kecepatan
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# 4. Putar tampilan menghadap arah gerak (halus)
	if direction.length() > 0.1:
		var target_angle := atan2(direction.x, direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, 10.0 * delta)

	move_and_slide()
```

Putar kamera dengan mouse (`_unhandled_input`, event `InputEventMouseMotion`):
- gerak mouse horizontal → `camera_pivot.rotate_y(...)`
- gerak mouse vertikal → ubah `spring_arm.rotation.x` lalu **`clamp`** supaya nggak muter 360°.
- `Input.mouse_mode = Input.MOUSE_MODE_CAPTURED` di `_ready()` (Esc untuk melepas).

**Langkah kerja:**
1. 🟢 Atur struktur scene player seperti di atas. SpringArm `spring_length` ≈ 4, Camera mengikuti.
2. 🟢 Tulis `player.gd`: gravitasi + jalan (belum lari/lompat).
3. 🟢 **Tes** (jalan dan gravitasi).
4. 🟢 Tambah kamera mouse + clamp pitch. **Tes.**
5. 🟢 Tambah lari (Shift) dan lompat (Space). **Tes.**
6. 🟢 Atur `@export` variabel (speed, jump_velocity, sensitivity) dan tuning dari Inspector.
7. 🟢 Tambahkan sedikit dinding/kotak di arena untuk menguji collision & kamera.

**Hasil yang harus terlihat:**
- W/A/S/D membawa player maju/kiri/mundur/kanan **sesuai arah kamera**.
- Capsule/tampilan menoleh ke arah jalan.
- Kamera berputar halus dan tidak bisa terbalik.
- Kamera tidak tembus dinding (SpringArm bekerja).
- Player tidak melayang dan tidak jatuh menembus lantai.

**Bug umum:**
| Gejala | Kemungkinan penyebab |
|---|---|
| Player jatuh menembus lantai | Lantai belum punya `CollisionShape3D` / layer-mask salah |
| Gerak terbalik | Tanda `input_dir.y` atau basis kamera terbalik |
| Kamera ikut berputar saat player menoleh | `Visual` tidak dipisah, atau kamera ada di dalam node yang diputar |
| Gerak jadi lambat saat melihat ke bawah | Lupa `direction.y = 0` sebelum `normalized()` |
| Kamera gemetar | Gerakan dilakukan di `_process`, harusnya `_physics_process`; atau SpringArm tanpa collision margin |

**Selesai jika:**
- [ ] Jalan, lari, lompat bekerja.
- [ ] Arah gerak mengikuti kamera.
- [ ] Kamera stabil dan tidak mengganggu kontrol.
- [ ] Tidak ada error di panel Output.
- [ ] Sudah di-commit: `Tahap 1: movement dan kamera`.

🔵 **Naik level:** akselerasi/deselerasi halus (pakai `move_toward`), coyote time (lompat sesaat setelah jatuh dari tepi), jump buffer.

---

### TAHAP 2 — Combat pemain

**Tujuan:** satu serangan melee yang konsisten dan tidak memberi damage ganda secara tidak sengaja.

**Konsep yang dipelajari:** state machine sederhana, `Area3D` sebagai hitbox, signal, cooldown, Timer, memisahkan "input → logika → damage".

**Pemisahan tanggung jawab (kunci rapi):**
```text
INPUT        → "attack ditekan?"                     (player.gd)
LOGIKA       → "boleh nyerang? mulai serangan"      (player.gd / state)
HITBOX       → "siapa yang kena?"                    (Area3D)
DAMAGE       → "kurangi health"                      (HealthComponent)
```
Jangan campur semuanya di satu fungsi.

**Struktur tambahan:**
```text
Player
├── ...
├── AttackHitbox (Area3D)        ← layer 4, mask 3, MONITORING MATI secara default
│   └── CollisionShape3D         (BoxShape3D di depan player)
├── AttackTimer (Timer, one_shot) ← durasi serangan aktif
├── CooldownTimer (Timer, one_shot)
└── HealthComponent (Node)       ← script health_component.gd
```
> Letakkan `AttackHitbox` di dalam `Visual` kalau mau hitbox ikut menghadap arah player.

**Komponen health (dipakai ulang oleh player DAN musuh):**
```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
```
Satu script ini dipakai di player dan musuh. Itu yang disebut **komponen**: tulis sekali, pasang di mana-mana.

**State yang dipakai:**
```gdscript
enum State { IDLE, MOVE, ATTACK, HURT, DEAD }
var state: State = State.IDLE
```
Aturan: di `ATTACK`, player tidak bisa bergerak bebas / tidak bisa menyerang lagi. Di `DEAD`, semua input diabaikan.

**Mencegah damage berulang (penting):**
```gdscript
var already_hit: Array = []   # dikosongkan setiap serangan baru dimulai

func start_attack():
	already_hit.clear()
	attack_hitbox.monitoring = true
	# ... mulai AttackTimer

func _on_attack_hitbox_body_entered(body):
	if body in already_hit:
		return
	already_hit.append(body)
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)
```
Tanpa `already_hit`, satu ayunan bisa kena berkali-kali.

**Langkah kerja:**
1. 🟢 Buat `health_component.gd` (script di atas). Tes: panggil `take_damage` dari kode, lihat print.
2. 🟢 Tambah enum state di player, dan pastikan gerak hanya jalan saat bukan `ATTACK`/`DEAD`.
3. 🟢 Tambah `AttackHitbox` + shape. Matikan `monitoring`. Tampilkan sementara (Debug → Visible Collision Shapes).
4. 🟢 Saat `attack` ditekan → state `ATTACK`, nyalakan hitbox, jalankan timer.
5. 🟢 Saat timer selesai → matikan hitbox, mulai cooldown, kembali ke `IDLE`.
6. 🟢 Tambah `already_hit`.
7. 🟢 Buat **dummy target**: `CharacterBody3D`/`StaticBody3D` di layer 3 dengan `HealthComponent`. Tes mukul dummy.
8. 🟢 Beri feedback visual sementara (dummy berubah warna/`print(health)`).

**Hasil yang harus terlihat:**
- Klik kiri → hitbox aktif sebentar (terlihat di debug shape), lalu mati.
- Dummy dipukul **1 kali per ayunan**, bukan 5 kali.
- Spam klik tidak menghasilkan serangan tanpa batas (ada cooldown).
- Menyerang ke arah lain tidak mengenai dummy di belakang.

**Bug umum:**
| Gejala | Kemungkinan penyebab |
|---|---|
| Hitbox tidak pernah kena | Layer/mask salah; `monitoring` tidak dinyalakan; dummy tidak punya collision |
| Damage berkali-kali | Lupa `already_hit` |
| Hitbox selalu aktif | Lupa mematikan di akhir serangan |
| `body.get_node` error | Target tidak punya `HealthComponent` → cek dulu dengan `has_node` |

**Selesai jika:**
- [ ] Satu serangan mengenai target secara konsisten.
- [ ] Tidak ada damage ganda per ayunan.
- [ ] Ada cooldown yang bekerja.
- [ ] Hitbox bisa dilihat lewat debug.
- [ ] Sudah di-commit.

🔵 **Naik level:** hit-stop (jeda 0.05 detik saat kena), knockback kecil pada target, serangan dengan "windup → aktif → recovery" (3 fase), buffer input serangan.

---

### TAHAP 3 — Musuh dasar

**Tujuan:** musuh mengejar player, menyerang saat dekat, bisa mati.

**Konsep yang dipelajari:** AI dengan state machine, jarak (`distance_to`), reuse `HealthComponent`, groups.

**Struktur scene musuh:**
```text
Enemy (CharacterBody3D)         ← layer 3, mask 1, masuk group "enemies"
├── Visual (Node3D)
│   └── MeshInstance3D          (capsule beda warna)
├── CollisionShape3D
├── AttackHitbox (Area3D)       ← layer 5, mask 2
│   └── CollisionShape3D
├── AttackTimer (Timer)
├── CooldownTimer (Timer)
└── HealthComponent (Node)
```

**Diagram state AI (sederhana, cukup 4 state):**
```text
IDLE ──(player dalam detect_range)──▶ CHASE
CHASE ──(jarak <= attack_range)──▶ ATTACK
ATTACK ──(selesai + cooldown)──▶ CHASE
(any) ──(health 0)──▶ DEAD
```
Cara berpikir AI: tiap frame tanya 3 hal berurutan:
1. Aku masih hidup?
2. Player seberapa jauh?
3. Berdasarkan jarak, aku harus ngapain?

**Logika chase minimal:**
```gdscript
var to_player := player.global_position - global_position
to_player.y = 0
var distance := to_player.length()
# CHASE: velocity = to_player.normalized() * chase_speed
# ATTACK: berhenti, nyalakan hitbox sekali, cooldown
```
Cara dapat referensi player: `get_tree().get_first_node_in_group("player")` (tambahkan player ke group `"player"`). Jadi musuh tidak perlu path hardcode.

**Langkah kerja:**
1. 🟢 Buat `enemy.tscn` dengan struktur di atas, tambah ke group `"enemies"`.
2. 🟢 Tambah `HealthComponent`, sambungkan signal `died` → hapus musuh (`queue_free()`), dulu cukup begitu.
3. 🟢 Tulis chase saja. **Tes**: musuh mengejar tanpa menyerang.
4. 🟢 Tambah serangan jarak dekat + cooldown + hitbox (pola sama dengan player).
5. 🟢 Hubungkan hitbox musuh → `HealthComponent` player.
6. 🟢 Ganti dummy di Tahap 2 dengan musuh asli. **Tes** bertarung.
7. 🟢 Tuning dengan `@export`: speed, range, damage, health, cooldown.

**Hasil yang harus terlihat:**
- Musuh mendekat saat player masuk jangkauan.
- Musuh berhenti dan menyerang saat dekat.
- Player bisa kena damage dan health turun (cek via `print` dulu).
- Musuh mati setelah beberapa pukulan.
- Musuh tidak menyerang berkali-kali dalam satu ayunan.

**Selesai jika:**
- [ ] Musuh mengejar dan menyerang.
- [ ] Player dan musuh saling memberi damage.
- [ ] Musuh bisa dikalahkan.
- [ ] AI masih sederhana (tidak ada pathfinding rumit).
- [ ] Sudah di-commit.

🔵 **Naik level:** `NavigationAgent3D` + `NavigationRegion3D` supaya musuh menghindari rintangan, state `HURT` (stagger sebentar saat kena), variasi sedikit di speed antar musuh, hindari musuh bertumpuk (jarak antar musuh).

---

### TAHAP 4 — Satu putaran permainan

**Tujuan:** game bisa dimulai, dimenangkan/dikalahkan, dan diulang. **Ini milestone terbesar.**

**Konsep yang dipelajari:** game state, signal antar sistem, UI dasar (Control/CanvasLayer), reload scene.

**Struktur:**
```text
Main (Node3D)
├── Arena
├── Player
├── Enemies (Node3D)             ← wadah semua musuh yang ditempatkan manual
│   ├── Enemy1 ... Enemy3
├── HUD (CanvasLayer)
│   ├── HealthBar (ProgressBar)
│   └── EnemyCountLabel (Label, opsional)
├── EndScreen (CanvasLayer)      ← disembunyikan di awal
│   ├── ResultLabel ("MENANG!" / "KALAH!")
│   └── RestartButton
└── GameManager (Node)           ← script game_manager.gd
```

**Tugas GameManager (kecil saja):**
```text
- Hitung musuh yang hidup  → saat musuh mati, hitungan berkurang
- Jika hitungan = 0        → menang
- Jika player.died         → kalah
- Menampilkan EndScreen
- Restart: get_tree().reload_current_scene()
```
Cara menghitung musuh: pakai signal `died` dari tiap musuh, atau `get_tree().get_nodes_in_group("enemies").size()` setelah `queue_free`. Pilih yang lebih mudah kamu pahami dulu.

**Pemain mati:** hentikan input player (state `DEAD`), tampilkan layar kalah.

**Restart:** tombol UI **dan** tombol `R`. Sebelum `reload_current_scene()`, pastikan `get_tree().paused` kembali `false`.

**Langkah kerja:**
1. 🟢 Tempatkan 3 musuh di arena (posisi manual).
2. 🟢 Buat HUD health bar. Sambungkan ke signal `health_changed` player (**jangan** polling tiap frame).
3. 🟢 Buat `GameManager`: hitung musuh, deteksi menang.
4. 🟢 Deteksi kalah dari `died` player.
5. 🟢 Buat EndScreen + tombol Restart.
6. 🟢 Tes satu putaran penuh: menang, restart, kalah, restart.

**Hasil yang harus terlihat:**
- Health bar turun saat player kena.
- Kalahkan semua musuh → muncul "MENANG".
- Health habis → muncul "KALAH".
- Restart mengembalikan semuanya (health penuh, musuh kembali, tidak ada sisa state).

**Bug umum:**
| Gejala | Kemungkinan penyebab |
|---|---|
| Setelah restart game freeze | `get_tree().paused` masih `true` |
| Mouse hilang di layar akhir | `mouse_mode` masih `CAPTURED` → set `VISIBLE` saat layar akhir muncul |
| Menang terpanggil berkali-kali | Cek kondisi tanpa flag `game_over` |
| Health bar tidak update | Signal belum tersambung |

**Selesai jika:**
- [ ] Game bisa mulai, menang, kalah, dan restart.
- [ ] Health pemain tampil.
- [ ] Bisa dimainkan 3x berturut-turut tanpa restart manual dari editor.
- [ ] Sudah di-commit + tag `v0.4-playable`.

🔵 **Naik level:** musuh muncul dalam gelombang (wave) sederhana, counter musuh di HUD, timer waktu penyelesaian, `Resource` custom untuk stat musuh (`EnemyStats`).

---

### TAHAP 5 — Greybox dan pengujian

**Tujuan:** game stabil dan terasa adil sebelum diberi aset.

**Konsep yang dipelajari:** greyboxing, playtest, debugging sistematis, balancing sederhana.

**Langkah kerja:**
1. 🟢 Bentuk arena dengan mesh sederhana: dinding, pilar, area awal dan "akhir" yang jelas.
2. 🟢 Atur posisi musuh supaya bertahap (bukan semua menyerbu sekaligus).
3. 🟢 **Tes terstruktur** — jalankan checklist di bawah.
4. 🟢 Perbaiki bug satu per satu. Catat di Log sebelum memperbaiki.
5. 🟢 Tuning angka: health, damage, speed, cooldown. Ubah **satu variabel per percobaan**.
6. 🟢 Minta 1–2 orang mencoba. **Jangan jelaskan apa-apa** — lihat di mana mereka bingung.

**Checklist tes:**
- [ ] Serang dari depan, samping, belakang: hitbox mengenai sesuai yang terlihat?
- [ ] Player menempel tembok sambil menyerang: ada bug?
- [ ] Dikepung 3 musuh: masih bisa dikontrol?
- [ ] Mati lalu restart 5x: tidak ada bug?
- [ ] Menang lalu restart 5x: tidak ada bug?
- [ ] Spam klik, spam lompat, spam restart: ada crash/error?
- [ ] Kamera di sudut sempit: tetap nyaman?
- [ ] Musuh tersangkut di dinding/pilar?
- [ ] Bisa jatuh keluar arena? (tambahkan batas/kill zone kalau iya)
- [ ] Panel Output bersih dari error/warning penting?

**Selesai jika:**
- [ ] Game bisa dimainkan berulang kali.
- [ ] Tidak ada bug yang menghalangi penyelesaian.
- [ ] Tingkat kesulitan wajar (tidak mustahil, tidak terlalu mudah).
- [ ] Sudah di-commit.

🔵 **Naik level:** pakai Godot Profiler / Monitors untuk cek FPS, tambah debug overlay (FPS, state player, health musuh) yang bisa dinyalakan dengan tombol.

---

### TAHAP 6 — Aset dan animasi

**Tujuan:** ganti placeholder dengan model/animasi **tanpa merusak** gameplay yang sudah jalan.

**Konsep yang dipelajari:** pipeline Blender → Godot (glTF), `AnimationPlayer` / `AnimationTree`, menghubungkan animasi ke state, material, audio.

**Prinsip utama:** **state gameplay adalah bosnya, animasi cuma mengikuti.**
```text
state berubah → mainkan animasi yang sesuai
(BUKAN: animasi selesai → ubah state gameplay)
```
Kecuali untuk hal tertentu (misalnya hitbox aktif di frame tertentu), itu pun baru dilakukan di versi naik level.

**Urutan kerja (jangan sekaligus):**
1. 🟢 **Model player sederhana** di Blender (blockout saja: badan + kepala + tangan). Export `.glb` ke `assets/models/`.
2. 🟢 Masukkan model ke dalam node `Visual`, **hapus** capsule mesh. Collision tetap capsule. **Tes**: kontrol masih sama.
3. 🟢 Animasi **idle**, lalu **walk/run**. Hubungkan ke state `IDLE`/`MOVE`. **Tes.**
4. 🟢 Animasi **attack**. Pastikan durasi cocok dengan `AttackTimer`. **Tes** hitbox masih konsisten.
5. 🟢 Animasi **hurt** dan **dead**.
6. 🟢 Ulangi versi sederhana untuk musuh.
7. 🟢 Material dasar, lalu efek serangan sederhana (misalnya flash/partikel kecil), lalu suara (pukulan, kena, mati).

**Tips:**
- Satu model/animasi → tes → baru lanjut. Jangan impor semuanya sekaligus.
- Skala di Blender: 1 unit = 1 meter agar cocok dengan Godot.
- Jangan ubah ukuran collision tanpa dites ulang combat.
- Kalau animasi bikin kontrol terasa lambat, **pendekkan animasinya**, jangan mengubah logika gameplay.

**Bug umum:**
| Gejala | Kemungkinan penyebab |
|---|---|
| Model terbalik arah | Forward axis berbeda; putar node `Visual` atau perbaiki saat export |
| Model terlalu besar/kecil | Skala di Blender tidak 1:1 |
| Animasi tidak jalan | Nama animasi tidak cocok dengan yang dipanggil di kode |
| Animasi loop saat tidak seharusnya | Loop mode animasi (attack/dead harus tidak loop) |

**Selesai jika:**
- [ ] Model + animasi dasar terpasang untuk player dan musuh.
- [ ] Kontrol dan combat terasa sama seperti sebelum aset ditambah.
- [ ] Hitbox masih konsisten.
- [ ] Sudah di-commit.

🔵 **Naik level:** `AnimationTree` dengan blend (idle↔walk↔run), animation event untuk memicu hitbox tepat di frame ayunan, root motion.

---

### TAHAP 7 — Penyelesaian

**Tujuan:** game utuh dari buka sampai tutup.

**Struktur tambahan:**
```text
MainMenu (Control)
├── Title (Label)
├── StartButton
├── ControlsLabel / panel instruksi
└── QuitButton
```
Flow: `MainMenu → (Start) → Level → (Menang/Kalah) → Restart / Menu`

**Langkah kerja:**
1. 🟢 Buat menu awal: Start, Keluar (`get_tree().quit()`).
2. 🟢 Buat panel kontrol (W/A/S/D, Shift, Space, Klik kiri, R, Esc).
3. 🟢 Pastikan alur menu → game → menang/kalah → restart/menu berfungsi.
4. 🟢 Tes satu rangkaian penuh dari membuka game sampai selesai.
5. 🟢 Catat bug yang tersisa; pastikan tidak ada yang menghalangi penyelesaian.
6. 🟢 Export build (Project → Export) dan tes file hasil export, bukan hanya dari editor.

**Selesai jika (Definisi selesai):**
- [ ] Ada awal (menu), gameplay inti, menang/kalah, dan cara main ulang.
- [ ] Instruksi kontrol tersedia.
- [ ] Tidak ada bug penghalang yang diketahui.
- [ ] Build export bisa dijalankan.
- [ ] Sudah di-commit + tag `v1.0`.

Visual tidak harus bagus.

🔵 **Naik level:** pause menu, pengaturan volume, simpan skor terbaik.

---

## 8. Aturan implementasi

- GDScript dulu.
- Buat satu sistem kecil → jalankan → uji → baru lanjut.
- Hindari satu script raksasa yang mengatur semua hal.
- Gunakan **signal** untuk komunikasi antar-sistem kalau akses langsung bikin ruwet.
- Pakai **komponen** (seperti `HealthComponent`) untuk logika yang dipakai berulang.
- Jangan membuat framework generik terlalu dini.
- Jangan tambah plugin/dependency tanpa alasan jelas.
- Setelah perubahan: jalankan dan uji fitur terdampak.
- Error: perbaiki error pertama yang relevan dulu.
- Catat keputusan penting dan cara menjalankan proyek di dokumen ini.

**Gaya kode yang konsisten:**
- Nama file/variabel/fungsi: `snake_case`. Nama class/node: `PascalCase`.
- Konstanta: `UPPER_CASE`.
- Beri tipe pada variabel (`var speed: float = 5.0`) supaya error ketahuan lebih awal.
- Angka yang sering diubah → `@export`, bukan angka tertanam di kode.
- Komentar menjelaskan **kenapa**, bukan mengulang **apa**.

---

## 9. Pola arsitektur kecil yang dipakai di proyek ini

Supaya kamu paham "kenapa kodenya diatur begini":

| Pola | Dipakai di | Manfaat |
|---|---|---|
| **State machine (enum + match)** | Player, Enemy | Perilaku jelas, mudah dilacak, anti "spaghetti if" |
| **Komponen** | `HealthComponent` | Satu kode, dipakai player & musuh |
| **Signal** | health_changed, died | Sistem tidak saling bergantung langsung |
| **Group** | `"player"`, `"enemies"` | Menemukan/menghitung node tanpa path hardcode |
| **`@export`** | Semua angka tuning | Tuning cepat tanpa mengubah kode |
| **Scene reuse** | `enemy.tscn` | Tambah musuh = drag & drop |

Contoh `match` untuk state (pola dasar):
```gdscript
func _physics_process(delta):
	match state:
		State.IDLE:   _state_idle(delta)
		State.MOVE:   _state_move(delta)
		State.ATTACK: _state_attack(delta)
		State.HURT:   _state_hurt(delta)
		State.DEAD:   pass
```

---

## 10. Cara menggunakan Claude sebagai asisten coding

Kerjakan **satu tahap dalam satu waktu**.

Untuk setiap tugas, Claude harus:
1. Menjelaskan tujuan dan konsep yang dipelajari secara singkat.
2. Menyebutkan scene dan script yang perlu dibuat atau diubah.
3. Memberikan implementasi sekecil mungkin untuk target aktif.
4. Menjelaskan bagian penting kode dengan bahasa pemula.
5. Memberikan langkah pengujian dan hasil yang seharusnya terlihat.
6. Tidak mengerjakan tahap berikutnya sebelum tahap aktif lolos tes.
7. Tidak menulis ulang file yang tidak terkait atau menghapus perilaku yang sudah bekerja.
8. Kalau info struktur proyek belum ada, **minta file/potongan kode yang relevan**, jangan menebak.

Pengguna ingin belajar, bukan menerima seluruh game dalam satu kali generate. Beri kesempatan untuk memahami, mengubah, dan mencoba kode sendiri.

### Template prompt (copy-paste, isi bagian `[...]`)

**Mulai tahap baru**
```text
Aku mengerjakan Project Breakpoint (Godot [versi], GDScript). Aku di Tahap [X]: [nama tahap].
Tahap sebelumnya sudah lolos tes. Ikuti aturan di plan.md bagian 10.
Mulai dari langkah [N]. Jelaskan konsepnya dulu, lalu beri implementasi sekecil mungkin.
```

**Ada error**
```text
Tahap [X], langkah [N]. Yang kuharapkan: [...]. Yang terjadi: [...].
Pesan error (persis dari panel Output): [...]
Struktur scene: [tempel tree node]
Script terkait: [tempel script]
Jelaskan penyebabnya dulu, lalu perbaikan minimal. Jangan ubah bagian lain.
```

**Review kode (belajar)**
```text
Ini script [nama] yang kutulis sendiri: [tempel]. Review dengan bahasa pemula:
apa yang sudah bagus, apa yang berisiko jadi bug, dan apa yang bisa dirapikan.
Jangan tulis ulang semuanya, tunjukkan bagian yang perlu diubah saja.
```

**Minta penjelasan konsep**
```text
Jelaskan [konsep, misal: signal / move_and_slide / collision mask] pakai analogi sederhana
dan contoh kecil di konteks game-ku. Setelah itu beri 1 latihan kecil yang bisa kucoba sendiri.
```

**Cek sebelum lanjut tahap**
```text
Ini checklist "Selesai jika" Tahap [X] dan hasil tesku: [...].
Menurutmu tahap ini sudah layak dianggap selesai? Apa yang masih kurang?
```

---

## 11. Kalau lagi stuck (urutan debugging)

1. **Baca pesan error** di panel Output dari atas. Fokus pada baris pertama (nama file + nomor baris).
2. **Cek yang sering salah:**
   - Nama node di `$Node` / `@onready` sama persis dengan di scene?
   - Layer/mask collision sesuai tabel 6.3?
   - Signal sudah tersambung? (ikon di tab Node → Signals)
   - Script menempel di node yang benar?
3. **Isolasi:** nonaktifkan bagian lain, tes bagian yang bermasalah saja.
4. **`print()`** nilai yang dicurigai: state, jarak, health, nama body yang kena.
5. **Debug visual:** `Debug → Visible Collision Shapes`, dan Remote tab saat game jalan untuk melihat node tree real-time.
6. **`git diff` / `git stash`:** apa yang berubah sejak terakhir jalan? Kembalikan perubahan kalau perlu.
7. Masih buntu setelah 30 menit → pakai template prompt "Ada error".

---

## 12. Log kerja (isi setiap selesai tahap)

Salin format ini untuk tiap entri:

```text
### Tahap X — [nama] — selesai tanggal: ____
- Commit: ____
- Yang berhasil: ____
- Bug yang ketemu & solusinya: ____
- Yang kupelajari: ____
- Keputusan penting: ____
```

**Info proyek (isi):**
- Versi Godot: ____
- Cara menjalankan: buka `project.godot` → tekan F5 (main scene: `scenes/main/main.tscn`)
- Platform target: ____

**Bug yang masih terbuka:**
| # | Deskripsi | Menghalangi penyelesaian? | Status |
|---|---|---|---|
| 1 | | | |

---

## 13. Ide nanti (parkir fitur di sini)

Setiap kali muncul ide baru di tengah pengerjaan, **tulis di sini dan lanjut kerja**. Jangan dikerjakan sampai MVP selesai.

- [ ]
- [ ]

---

## 14. Checklist penyelesaian akhir

- [ ] Proyek dapat dijalankan.
- [ ] Gerakan dan kamera berfungsi.
- [ ] Serangan pemain berfungsi.
- [ ] Musuh dapat menyerang dan menerima damage.
- [ ] Kondisi menang dan kalah berfungsi.
- [ ] Restart berfungsi.
- [ ] Satu arena dapat diselesaikan dari awal sampai akhir.
- [ ] Tidak ada bug penghalang yang diketahui.
- [ ] Aset dan animasi dasar sudah terhubung.
- [ ] Game dapat dimainkan ulang tanpa perlu mengubah kode secara manual.
- [ ] Build export berjalan di luar editor.

**Prinsip proyek:** selesaikan versi sederhana terlebih dahulu. Konten tambahan dan visual yang lebih bagus adalah pengembangan berikutnya, bukan alasan untuk menunda versi yang sudah bisa dimainkan.
