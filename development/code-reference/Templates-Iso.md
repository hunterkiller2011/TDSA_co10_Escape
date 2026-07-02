# Code Reference — Iso Data-Templates (roadblocks)
_Last updated: 2026-07-02 (local)_ · _Status: documented_

> `Code/templates/*.sqf` — the live Iso data-templates loaded by `A3E_fnc_LoadTemplates` and rebuilt by
> `A3E_fnc_isoTemplateRestore` for the roadblock system (`A3E_fnc_RoadBlocks`). These are DATA (nested arrays), not functions.
> How the system works: `A3E_RoadblockTemplates` (per-mod, in `Mods/*/UnitClasses.sqf`) names which of these load;
> RoadBlocks picks one, restores the scenery, and spawns manned vehicles/gunners into the `parkedvehicles`/`statics` slots.

## How the data is shaped and consumed

Each file is a single nested array in **"Iso" pair-list format** — a list of `[key, value]` pairs read with
`BIS_fnc_getFromPairs`. Top-level keys:

- **`Name`** — string id; must match the string listed in a mod's `A3E_RoadblockTemplates`. This is how
  `A3E_fnc_isoTemplateRestore` finds the template (`findIf` on `"Name"`).
- **`Clearance`** — footprint `[a, b, angle, isRect, c]` passed to `inArea`. On restore, every
  `nearestTerrainObjects` inside this box (rotated by the roadblock's dir) is `hideObject`'d so map clutter
  (walls, fences, trees) doesn't clip through the placed composition. `a`/`b` are the half-extents.
- **`Objects`** — the composition. Each object is `[type, pos, dir, attributes, childObjects]` where:
  - `pos` is **relative** to the roadblock centre (rotated at restore time via `A3E_fnc_rotatePosition`).
  - `attributes` is a pair-list turned into a HashMap. Relevant flags:
    - `spawn` (default **true**) → the object is `createVehicle`'d as **scenery** immediately.
    - `spawn=false` + `parkedvehicle=true` → **not** created as scenery; instead a `[type,pos,dir,init]` entry
      is pushed into the returned `parkedvehicles` slot list. `parkedvehicletype` ("Armed"/…) is metadata only.
    - `spawn=false` + `static=true` → pushed into the returned `statics` slot list (`statictype` is metadata).
    - `spawn=false` + `ammobox=true` → pushed into the returned `ammoboxes` slot list (**no template uses this**).
    - cosmetic/gameplay flags handled by `_createObject`: `terminal`, `indestructable`, `yeet`, `inflame`, `init`.
  - `childObjects` — nested objects positioned relative to their parent (used to seat a static MG on a bunker/tower).
    In these files the child is always an `spawn=false` `static` (the gun slot), so it becomes a `statics` entry too.
  - `sourceobj` — an Eden/editor provenance string (object id or `.p3d` name). **Documentation only**, unused at runtime.

**What RoadBlocks does with the slots** (`A3E_fnc_RoadBlocks`): it ignores the concrete `parkedvehicletype`/
`statictype`/vehicle classnames baked into the template and instead spawns **from the per-mod random arrays** at the
recorded positions — `parkedvehicles` slots → a `BIS_fnc_spawnVehicle` from `a3e_arr_Escape_RoadBlock_MannedVehicleTypes`
(or `…_Ind` for the independent side); `statics` slots → a `createVehicle` from `a3e_arr_ComCenStaticWeapons` +
`A3E_fnc_AddStaticGunner`. So the `B_APC_Wheeled_01_cannon_F` / `B_HMG_01_high_F` / mod-specific gun classnames in
the data are **placeholders marking a slot + facing**, not the units that actually spawn. (Scenery objects with
`spawn=true`, however, ARE created with their literal classnames.)

## Reference map — which mods list which template

`A3E_RoadblockTemplates` lives in each `Mods/*/UnitClasses.sqf`. Vanilla's default list is `rb_bis_rb1-3`.

| Template | Listed by (`A3E_RoadblockTemplates`) |
|----------|--------------------------------------|
| `rb_bis_rb1` | Vanilla, CSLA-US, SFP, SFP w, SFP d |
| `rb_bis_rb2` | Vanilla, CSLA-US, SFP, SFP w, SFP d, **and all 3 SOGPF variants** |
| `rb_bis_rb3` | Vanilla, CSLA-US, SFP, SFP w, SFP d |
| `rb_bis_rb4` | CSLA-US, SFP, SFP w, SFP d (**not** in Vanilla's default list) |
| `rb_gm_rb1` | GM-BW, GM-BW w, GM-NVA, GM-NVA w |
| `rb_gm_rb2` | GM-BW, GM-BW w, GM-NVA, GM-NVA w |
| `rb_gm_rb3` | GM-BW, GM-BW w, GM-NVA, GM-NVA w |
| `rb_gm_rb4` | GM-BW, GM-BW w, GM-NVA, GM-NVA w |
| `rb_spe_rb1` | SPE GER vs US, SPE US vs GER |
| `rb_vn_rb1` | SOGPF MACV vs PAVN-VC, SOGPF PAVN vs MACV-ARVN, SOGPF PAVN vs ANZAC-ROK |
| `rb_vn_rb2` | SOGPF MACV vs PAVN-VC, SOGPF PAVN vs MACV-ARVN, SOGPF PAVN vs ANZAC-ROK |

**Every one of the 11 files is referenced by at least one mod** — none are orphaned. (Note: the README's
example that "`rb_bis_rb4` is NOT referenced" is inaccurate — it is listed by CSLA-US and all SFP variants. It is
merely absent from the *Vanilla default* list. See CONCERNS.)

---

### rb_bis_rb1  —  `Code/templates/rb_bis_rb1.sqf`
- **Defines:** vanilla (Arma 3 CfgVanilla assets) checkpoint, **small**. Clearance `[12,15,…]`.
- **Referenced by:** Vanilla (default `rb_bis_rb1-3`), CSLA-US, SFP/SFP w/SFP d.
- **Structure:** a bag-bunker tower (`Land_BagBunker_Tower_F`) with a **child** HMG gun slot on top
  (`B_HMG_01_high_F`, `spawn=false static`), razorwire, and stacked H-barriers as scenery; plus one **parked-vehicle
  slot** (`B_APC_Wheeled_01_cannon_F`, `spawn=false parkedvehicle "Armed"`). Slots: **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** all scenery classnames are base-game (`Land_BagBunker_Tower_F`, `Land_Razorwire_F`,
  `Land_HBarrier_5_F`) so this composition is safe on any map/mod. The APC + HMG classnames are placeholders (see
  system note) — the real units come from the mod's random arrays. Two `Land_HBarrier_5_F` are stacked at z=0 and z=1.3
  (deliberate wall-height doubling).
- **Reforger port notes:** natural fit for an Enfusion **composition/prefab**: the scenery objects become static
  prefab children; the `parkedvehicles`/`statics` slots become **spawn-point entities/anchors** (empty markers with a
  facing) that the port's roadblock spawner fills from a faction table — mirror the "slot marks position+facing, faction
  table supplies the actual entity" split rather than baking classnames.

### rb_bis_rb2  —  `Code/templates/rb_bis_rb2.sqf`
- **Defines:** vanilla checkpoint, **small/compact**, concrete-barrier chicane. Clearance `[13,9,…]`.
- **Referenced by:** Vanilla (default), CSLA-US, SFP variants, **and all 3 SOGPF (Vietnam) variants** (used as filler
  alongside `rb_vn_*`).
- **Structure:** a fan of `Land_CncBarrier_F` concrete blocks + two `RoadBarrier_F` swing barriers (scenery); a bag-bunker
  tower with **two** child HMG gun slots (one flagged `probability=33`); one parked-vehicle slot. Slots: **1 parkedvehicle
  + 2 statics** (note: `probability` is a per-object attribute in the data but `isoTemplateRestore` does **not** read it —
  both gun slots are always emitted; see CONCERNS).
- **Whys & questions / concerns:** all base-game classnames → cross-mod safe (which is why SOGPF reuses it). The
  `["probability",33]` attribute on the second bunker gun is **dead data** — nothing in `isoTemplateRestore`/`RoadBlocks`
  consumes it.
- **Reforger port notes:** same slot/anchor mapping as rb1. The unused `probability` flag hints at an intended
  "sometimes-present" object feature — worth implementing properly in the port (weighted optional children) rather than
  carrying it as a no-op.

### rb_bis_rb3  —  `Code/templates/rb_bis_rb3.sqf`
- **Defines:** vanilla checkpoint, **small**, a bar-gate with bag-fence wings. Clearance `[15,7,…]`.
- **Referenced by:** Vanilla (default), CSLA-US, SFP variants.
- **Structure:** `Land_BarGate_F` centre, symmetric `Land_BagFence_Round_F`/`Land_BagFence_End_F` scenery; one **top-level**
  static HMG slot (`B_HMG_01_high_F`, `spawn=false static`, no bunker parent); one parked-vehicle slot. Slots:
  **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** base-game classnames only → cross-mod safe. Unlike rb1/rb2 the gun slot is free-standing
  (not a bunker child), so its `dir` is the only thing seating the gunner.
- **Reforger port notes:** trivial composition; the gate + fence wings become a prefab, the gun and APC become anchors.

### rb_bis_rb4  —  `Code/templates/rb_bis_rb4.sqf`
- **Defines:** vanilla checkpoint, **large** — the biggest bis roadblock (large clearance `[25,25,…]`), a full walled
  compound.
- **Referenced by:** CSLA-US, SFP/SFP w/SFP d. **NOT** in Vanilla's default `rb_bis_rb1-3` list — so on a plain Vanilla
  build this composition never spawns even though the file loads fine.
- **Structure:** ~40 scenery objects — `Land_Mil_ConcreteWall_F` perimeter, many `Land_HBarrier_*` / `Land_BagFence_*`,
  a `Land_PowerGenerator_F` + `Land_TTowerSmall_2_F`, camonets, lamps, paper boxes, bar-gate. Manned slots: a bag-bunker
  tower with **two** child HMG slots (one `probability=33`) and a `Land_Cargo_Patrol_V1_F` watchtower with **one** child
  HMG slot (`probability=33`). Slots: **0 parkedvehicles + 3 statics** — notably this template has **no parked-vehicle
  slot**, so RoadBlocks spawns no manned vehicle here, only static gunners.
- **Whys & questions / concerns:** base-game classnames → cross-mod safe. Two oddities: (1) it's excluded from the Vanilla
  default list despite being a Vanilla-asset composition (intentional? size/perf? — Q candidate); (2) no `parkedvehicle`
  slot means a very different threat profile (static-only) vs rb1-3. Same dead `probability=33` flags as rb2.
- **Reforger port notes:** larger "fortified checkpoint" prefab; good candidate to keep as a distinct size tier. Decide
  deliberately whether the port's Vanilla config includes it.

### rb_gm_rb1  —  `Code/templates/rb_gm_rb1.sqf`
- **Defines:** Global Mobilization (Cold-War Germany) checkpoint, **medium**. Clearance `[18,10,…]`.
- **Referenced by:** GM-BW, GM-BW w, GM-NVA, GM-NVA w.
- **Structure:** GM sandbag/bunker scenery (`land_gm_woodbunker_01_bags`, `land_gm_sandbags_01_*`, `land_gm_sandbags_02_wall`,
  `gm_berm_*`, `land_gm_camonet_*`, `gm_barrel`) as scenery; **two** GM tripod-MG static slots
  (`gm_ge_army_mg3_aatripod`, `spawn=false static`) and one parked-vehicle slot (`B_APC_Wheeled_01_cannon_F` placeholder).
  Slots: **1 parkedvehicle + 2 statics**.
- **Whys & questions / concerns:** **mod-dependent scenery** — every `gm_*`/`land_gm_*` classname requires the Global
  Mobilization CDLC loaded; on a build without GM these `createVehicle` calls fail (empty object). That's why the file is
  only listed by GM mods. The static gun placeholder is `gm_ge_army_mg3_aatripod` (also GM-dependent) but is a slot, so
  the actual gun comes from `a3e_arr_ComCenStaticWeapons`. The parked APC placeholder is oddly a base-game class inside a
  GM template (harmless — placeholder only).
- **Reforger port notes:** the GM-specific fortification objects have no direct Reforger equivalent — map to the nearest
  Enfusion fortification prefabs (sandbag walls, wood bunker, camo nets) per the target faction; keep the slot/anchor split.

### rb_gm_rb2  —  `Code/templates/rb_gm_rb2.sqf`
- **Defines:** GM checkpoint, **small**. Clearance `[12,8,…]`.
- **Referenced by:** GM-BW, GM-BW w, GM-NVA, GM-NVA w.
- **Structure:** GM sandbag walls + `gm_berm_01_used`/`gm_berm_02` + one `land_gm_camonet_02_east` (scenery); one static
  HMG slot (`B_HMG_01_high_F` placeholder, `spawn=false`) and one parked-vehicle slot. Slots: **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** GM-dependent scenery (`land_gm_*`, `gm_berm_*`). Here the static slot placeholder is the
  base-game `B_HMG_01_high_F` (vs the GM tripod in rb1) — inconsistent placeholder choice across GM templates, but
  cosmetically irrelevant since it's a slot.
- **Reforger port notes:** compact sandbag-berm checkpoint prefab; straightforward.

### rb_gm_rb3  —  `Code/templates/rb_gm_rb3.sqf`
- **Defines:** GM checkpoint, **medium**, berm/mudpit emplacement. Clearance `[18,10,…]`.
- **Referenced by:** GM-BW, GM-BW w, GM-NVA, GM-NVA w.
- **Structure:** `gm_berm_01/02/03(_used)`, `gm_mudpit_01`, `gm_placeholder_2x2x2`, `land_gm_camonet_02_east` scenery;
  **two** static HMG slots (`B_HMG_01_high_F` placeholders, one flagged `probability=33`) and one parked-vehicle slot.
  Slots: **1 parkedvehicle + 2 statics**.
- **Whys & questions / concerns:** GM-dependent scenery. Uses `gm_placeholder_2x2x2` — a **GM editor placeholder object**;
  intentional or leftover from composition authoring? (Q candidate). Dead `probability=33` flag again.
- **Reforger port notes:** the `gm_placeholder_*` and `gm_mudpit_*` are GM-flavour terrain dressing — replace with a
  dug-in/berm emplacement prefab. Slot mapping unchanged.

### rb_gm_rb4  —  `Code/templates/rb_gm_rb4.sqf`
- **Defines:** GM checkpoint, **very small** (single-emplacement). Clearance `[12,6,…]` — the tightest footprint of the set.
- **Referenced by:** GM-BW, GM-BW w, GM-NVA, GM-NVA w.
- **Structure:** one `land_gm_woodbunker_01_bags` + a couple sandbag walls, `gm_barrel_rusty`, a camonet (scenery); one GM
  tripod-MG static slot (`gm_ge_army_mg3_aatripod`) and one parked-vehicle slot. Slots: **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** GM-dependent scenery + GM tripod placeholder. Smallest template — barely more than a
  bunker + gun + vehicle.
- **Reforger port notes:** minimal wood-bunker + vehicle prefab; the low-complexity baseline of the GM set.

### rb_spe_rb1  —  `Code/templates/rb_spe_rb1.sqf`
- **Defines:** SPE (Spearhead 1944 / WWII) checkpoint, **small**, German-flavour. Clearance `[12,8,…]`.
- **Referenced by:** SPE GER vs US, SPE US vs GER. **Only one SPE template exists** (no rb2+), so every SPE roadblock uses
  this same composition.
- **Structure:** WWII SPE scenery (`Land_SPE_Sandbag_*`, `Land_SPE_BarbedWire_04`, `Land_SPE_Ammocan_German`,
  `Land_SPE_Ammobox_German_05`, `Land_SPE_Mud_Decal`, `Land_RoadBarrier_01_F`); one static slot **`SPE_ST_MG34_Bipod`**
  (`spawn=false static`) and one parked-vehicle slot **`SPE_OpelBlitz_Flak38`** (`spawn=false parkedvehicle "Armed"`).
  Slots: **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** **SPE-mod-dependent** — all `SPE_*`/`Land_SPE_*` classnames need the Spearhead 1944
  CDLC. Note the parked-vehicle placeholder here is a period-correct `SPE_OpelBlitz_Flak38` (Flak truck) rather than the
  base-game APC used in the bis/gm/vn templates — but it's still just a slot; the real vehicle comes from
  `a3e_arr_Escape_RoadBlock_MannedVehicleTypes` (SPE trucks/halftracks in the SPE mod config). Only having **one** SPE
  template means low variety on SPE maps (RD/Q candidate — consider authoring rb_spe_rb2+).
- **Reforger port notes:** WWII-specific dressing → nearest Enfusion equivalents; the Flak-truck and MG34 remain anchors
  filled from a WWII faction table. Variety gap worth closing in the port.

### rb_vn_rb1  —  `Code/templates/rb_vn_rb1.sqf`
- **Defines:** SOG Prairie Fire (Vietnam) checkpoint, **large** (clearance `[25,20,…]`) — note the non-zero angle field
  (`0.035`) in the clearance tuple. Pillbox-bunker style.
- **Referenced by:** SOGPF MACV vs PAVN-VC, SOGPF PAVN vs MACV-ARVN, SOGPF PAVN vs ANZAC-ROK.
- **Structure:** VN bag-fence scenery (`Land_vn_bagfence_*`), a `Land_vn_pillboxbunker_02_hex_f` bunker with a **child**
  M60 gun slot (`vn_b_army_static_m60_high`, `spawn=false static`), a base-game `Land_BarGate_F` gate, and one
  parked-vehicle slot. Slots: **1 parkedvehicle + 1 static**.
- **Whys & questions / concerns:** **SOGPF-mod-dependent** (`Land_vn_*`, `vn_b_*` classnames need SOG Prairie Fire CDLC);
  mixes in a base-game `Land_BarGate_F` (present in vanilla, safe under SOGPF). The clearance `angle=0.035` is an odd tiny
  non-zero rotation baked in — likely an authoring artifact (Q candidate). The static placeholder is a real VN M60
  classname (still just a slot).
- **Reforger port notes:** Vietnam pillbox + gate prefab; the M60 and vehicle become anchors filled from a VN faction table.

### rb_vn_rb2  —  `Code/templates/rb_vn_rb2.sqf`
- **Defines:** SOGPF (Vietnam) checkpoint, **large** (clearance `[25,20,0.035,…]`) — watchtower style.
- **Referenced by:** SOGPF MACV vs PAVN-VC, SOGPF PAVN vs MACV-ARVN, SOGPF PAVN vs ANZAC-ROK.
- **Structure:** a `Land_vn_b_tower_01` watchtower with a **child** .50-cal gun slot (`vn_b_army_static_m2_high`,
  `spawn=false static`), VN trench-revetment scenery (`Land_vn_b_trench_revetment_*`), a base-game `Land_BarGate_F` gate,
  and one parked-vehicle slot. Slots: **1 parkedvehicle + 1 static** (the static is elevated on the tower).
- **Whys & questions / concerns:** SOGPF-mod-dependent scenery/gun; base-game gate reused. Same `angle=0.035` clearance
  artifact as rb_vn_rb1. Complements rb_vn_rb1 (tower vs pillbox) for variety on VN maps.
- **Reforger port notes:** elevated-gun watchtower prefab; the tower-mounted gun slot is a good test of the port's
  "child anchor with height offset" handling (child pos z ≈ 4.34).

---

## CONCERNS (candidate tracker entries — not filed here)

- **BUG/RD — README example wrong about `rb_bis_rb4`.** The Coverage table in
  `development/code-reference/README.md` (and this doc's prompt) states `rb_bis_rb4` is "NOT referenced anywhere". It IS
  referenced by CSLA-US and all three SFP variants; it is only absent from the *Vanilla default* list. No file in
  `Code/templates/` is actually orphaned. (Doc-accuracy fix.)
- **RD — dead `probability` attribute.** `["probability",33]` appears on optional gun slots in `rb_bis_rb2`,
  `rb_bis_rb4`, `rb_gm_rb3`, but neither `A3E_fnc_isoTemplateRestore` nor `A3E_fnc_RoadBlocks` reads it — those slots are
  always emitted. Either the intended "sometimes present" behaviour was never implemented, or it was lost. (Tech debt /
  feature gap.)
- **RD — `ammobox` slot type is fully unused.** `isoTemplateRestore` supports an `ammoboxes` return slot and `RoadBlocks`
  never reads it; no roadblock template declares one anyway. Dead branch on both sides.
- **Q — placeholder classname inconsistency.** Parked/static slot placeholders vary (base-game `B_APC_Wheeled_01_cannon_F`
  / `B_HMG_01_high_F` in most; GM tripods in gm_rb1/rb4; period SPE `SPE_OpelBlitz_Flak38` in spe_rb1). Since these are
  only slot markers, the choice is cosmetic — but the inconsistency suggests copy-paste authoring; confirm none is
  accidentally relied on.
- **Q — content-variety gaps.** SPE has only **one** roadblock template (`rb_spe_rb1`); Vanilla's default list omits the
  large `rb_bis_rb4`. Consider authoring more SPE variants and/or adding rb4 to Vanilla for variety.
- **Q — clearance `angle=0.035` in `rb_vn_rb1`/`rb_vn_rb2`.** Tiny non-zero rotation baked into the clearance tuple; all
  other templates use `0`. Likely an Eden export artifact — confirm it's intentional (negligible effect on the hide-box).
- **RD (context) — RoadBlocks ignores baked slot classnames.** By design the manned vehicles/gunners come from per-mod
  random arrays (`a3e_arr_Escape_RoadBlock_MannedVehicleTypes[_Ind]`, `a3e_arr_ComCenStaticWeapons`), so the vehicle/gun
  classnames in these templates are placeholders. Worth stating explicitly in the port so the composition↔faction split
  is preserved rather than someone "fixing" the placeholders.

## Revision History

| Date | Author | Change |
|------|--------|--------|
| 2026-07-02 | Claude | Documented all entries |
