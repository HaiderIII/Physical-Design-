# Commandes OpenROAD : Die and Core Area

## Table des matieres

1. Initialize Floorplan
2. Report Commands
3. Modification du Floorplan
4. Export et Sauvegarde
5. Variables TCL utiles
6. Exemples complets

---

## 1. Initialize Floorplan

### 1.1 Syntaxe de base

Commande principale :
  initialize_floorplan [options]

Options disponibles :
  -die_area "llx lly urx ury"    : Coordonnees du die (microns)
  -core_area "llx lly urx ury"   : Coordonnees du core (microns)
  -site <site_name>              : Nom du site (depuis LEF)
  -utilization <percent>         : Taux d'utilisation (0-100)
  -aspect_ratio <ratio>          : Ratio hauteur/largeur
  -core_space <distance>         : Espace core-die (microns)

Note : 
  llx lly = lower-left x,y (coin inferieur gauche)
  urx ury = upper-right x,y (coin superieur droit)

### 1.2 Mode 1 : Coordonnees explicites

Definition manuelle complete :

  initialize_floorplan \
      -die_area "0 0 1000 1000" \
      -core_area "100 100 900 900" \
      -site core

Avantages :
  + Controle total des dimensions
  + Reproductible
  + Bon pour designs avec contraintes strictes

Inconvenients :
  - Calculs manuels necessaires
  - Risque d'erreur de dimensionnement

### 1.3 Mode 2 : Utilization automatique

Definition par utilization :

  initialize_floorplan \
      -utilization 70 \
      -aspect_ratio 1.0 \
      -core_space 100 \
      -site core

Avantages :
  + OpenROAD calcule automatiquement
  + Rapide pour exploration
  + Bon pour prototypage

Inconvenients :
  - Moins de controle precis
  - Peut necessiter ajustements

### 1.4 Mode 3 : Hybride

Fixer le die, calculer le core :

  initialize_floorplan \
      -die_area "0 0 2000 2000" \
      -utilization 75 \
      -site core

Ou fixer le core, calculer le die :

  initialize_floorplan \
      -core_area "100 100 1900 1900" \
      -core_space 50 \
      -site core

---

## 2. Report Commands

### 2.1 report_design_area

Affiche les informations du floorplan :

  report_design_area

Output typique :
  Design area 1000000 u^2 100% 
  Die area 1587600 u^2 100% 
  Core area 1000000 u^2 63% 
  Std cell area 700000 u^2 70%

Interpretation :
  - Design area : Total cell area
  - Die area : Surface du die
  - Core area : Surface du core
  - Std cell area : Cellules placees

### 2.2 report_checks

Verification du floorplan :

  report_checks -verbose

Verifie :
  - Utilization dans les limites
  - Core dans le die
  - Rows alignes
  - Sites valides

### 2.3 Commandes supplementaires

Lister les sites disponibles :
  
  report_lib_cell_sites

Afficher les rows :

  report_rows

Obtenir les dimensions :

  set die_area [ord::get_die_area]
  puts "Die: $die_area"

---

## 3. Modification du Floorplan

### 3.1 Redimensionner le core

Methode 1 : Re-initialiser completement

  initialize_floorplan \
      -die_area "0 0 1200 1200" \
      -core_area "100 100 1100 1100" \
      -site core

Methode 2 : Modifier incrementalement (avance)

  # Necessite manipulation directe de la DB
  # Non recommande pour debutants

### 3.2 Changer l'utilization

Recalculer avec nouvelle utilization :

  # Sauvegarder l'ancien
  write_def old_floorplan.def
  
  # Reinitialiser
  initialize_floorplan \
      -utilization 75 \
      -aspect_ratio 1.0 \
      -core_space 100 \
      -site core

### 3.3 Ajuster l'aspect ratio

Tester plusieurs ratios :

  foreach ar {0.5 0.7 1.0 1.5 2.0} {
    initialize_floorplan \
        -utilization 70 \
        -aspect_ratio $ar \
        -core_space 100 \
        -site core
    
    report_design_area
    write_def floorplan_ar${ar}.def
  }

---

## 4. Export et Sauvegarde

### 4.1 write_def

Sauvegarder le floorplan en DEF :

  write_def floorplan.def

Avec options :

  write_def -version 5.8 floorplan.def

### 4.2 Sauvegarder la database OpenROAD

Format natif OpenROAD :

  write_db floorplan.odb

Avantages :
  + Plus rapide a recharger
  + Conserve toutes les informations
  + Format compresse

### 4.3 Charger un floorplan existant

Depuis DEF :

  read_def floorplan.def

Depuis ODB :

  read_db floorplan.odb

---

## 5. Variables TCL utiles

### 5.1 Recuperer les dimensions

Die area :

  set die_area [ord::get_die_area]
  set die_llx [lindex $die_area 0]
  set die_lly [lindex $die_area 1]
  set die_urx [lindex $die_area 2]
  set die_ury [lindex $die_area 3]
  
  set die_width [expr $die_urx - $die_llx]
  set die_height [expr $die_ury - $die_lly]
  
  puts "Die: ${die_width} x ${die_height} um"

Core area :

  set core_area [ord::get_core_area]
  set core_llx [lindex $core_area 0]
  set core_lly [lindex $core_area 1]
  set core_urx [lindex $core_area 2]
  set core_ury [lindex $core_area 3]
  
  set core_width [expr $core_urx - $core_llx]
  set core_height [expr $core_ury - $core_lly]
  
  puts "Core: ${core_width} x ${core_height} um"

### 5.2 Calculer l'utilization

Total cell area :

  set design [ord::get_db_block]
  set total_cell_area 0
  
  foreach inst [$design getInsts] {
    set master [$inst getMaster]
    set area [expr [$master getWidth] * [$master getHeight]]
    set total_cell_area [expr $total_cell_area + $area]
  }
  
  puts "Total cell area: $total_cell_area um^2"

Utilization reelle :

  set core_area_value [expr $core_width * $core_height]
  set util [expr ($total_cell_area / $core_area_value) * 100.0]
  
  puts "Utilization: [format %.2f $util]%"

### 5.3 Calculer l'aspect ratio

  set aspect_ratio [expr double($core_height) / $core_width]
  puts "Aspect ratio: [format %.2f $aspect_ratio]"

### 5.4 Nombre de rows

  set site_height [[[lindex [ord::get_db_tech] 0] findSite "core"] getHeight]
  set num_rows [expr int($core_height / $site_height)]
  
  puts "Number of rows: $num_rows"

---

## 6. Exemples complets

### 6.1 Exemple 1 : Floorplan simple

Script complet :

  # Charger la techno et le design
  read_lef tech.lef
  read_lef stdcells.lef
  read_verilog design.v
  link_design top
  
  # Creer le floorplan
  initialize_floorplan \
      -utilization 70 \
      -aspect_ratio 1.0 \
      -core_space 100 \
      -site core
  
  # Verifier
  report_design_area
  report_checks
  
  # Sauvegarder
  write_def floorplan.def

### 6.2 Exemple 2 : Floorplan avec contraintes

Contrainte : Die max 1500x1500 um

  # Calculer core necessaire
  set target_util 0.75
  set total_cell_area 800000
  set core_area_needed [expr $total_cell_area / $target_util]
  
  puts "Core area needed: $core_area_needed um^2"
  
  # Core space
  set core_space 120
  
  # Calculer dimensions core
  set core_width [expr sqrt($core_area_needed)]
  set core_height $core_width
  
  # Calculer die
  set die_width [expr $core_width + 2*$core_space]
  set die_height [expr $core_height + 2*$core_space]
  
  puts "Die: ${die_width} x ${die_height} um"
  
  # Verifier contrainte
  if {$die_width > 1500 || $die_height > 1500} {
    puts "ERROR: Die exceeds constraint!"
    exit 1
  }
  
  # Creer floorplan
  initialize_floorplan \
      -die_area "0 0 $die_width $die_height" \
      -core_area "$core_space $core_space \
                  [expr $die_width-$core_space] \
                  [expr $die_height-$core_space]" \
      -site core

### 6.3 Exemple 3 : Explorer plusieurs configurations

Tester differentes utilisations :

  set utilizations {60 65 70 75 80}
  
  foreach util $utilizations {
    puts "\n=== Testing utilization: $util% ==="
    
    initialize_floorplan \
        -utilization $util \
        -aspect_ratio 1.0 \
        -core_space 100 \
        -site core
    
    # Reporter les metriques
    report_design_area
    
    # Sauvegarder
    write_def floorplan_util${util}.def
    
    # Calculer densite
    set die_area [ord::get_die_area]
    set core_area [ord::get_core_area]
    
    set die_w [expr [lindex $die_area 2] - [lindex $die_area 0]]
    set die_h [expr [lindex $die_area 3] - [lindex $die_area 1]]
    set core_w [expr [lindex $core_area 2] - [lindex $core_area 0]]
    set core_h [expr [lindex $core_area 3] - [lindex $core_area 1]]
    
    puts "Die: ${die_w} x ${die_h}"
    puts "Core: ${core_w} x ${core_h}"
  }

### 6.4 Exemple 4 : Floorplan avec verification

Script robuste avec checks :

  proc create_floorplan {util ar core_sp} {
    puts "Creating floorplan: util=$util AR=$ar spacing=$core_sp"
    
    # Tenter de creer
    if {[catch {
      initialize_floorplan \
          -utilization $util \
          -aspect_ratio $ar \
          -core_space $core_sp \
          -site core
    } err]} {
      puts "ERROR: $err"
      return 0
    }
    
    # Verifier
    set checks_ok [report_checks]
    if {!$checks_ok} {
      puts "WARNING: Checks failed"
      return 0
    }
    
    # Success
    puts "Floorplan created successfully"
    return 1
  }
  
  # Utiliser la procedure
  if {[create_floorplan 70 1.0 100]} {
    write_def good_floorplan.def
  }

---

## 7. Commandes de debug

### 7.1 Afficher les proprietes du design

  set block [ord::get_db_block]
  puts "Design: [$block getName]"
  puts "Num instances: [llength [$block getInsts]]"
  puts "Num nets: [llength [$block getNets]]"

### 7.2 Lister tous les sites

  set tech [ord::get_db_tech]
  foreach site [$tech getSites] {
    puts "Site: [$site getName]"
    puts "  Width: [$site getWidth]"
    puts "  Height: [$site getHeight]"
    puts "  Class: [$site getClass]"
  }

### 7.3 Verifier les rows

  set block [ord::get_db_block]
  set rows [$block getRows]
  
  puts "Number of rows: [llength $rows]"
  foreach row $rows {
    puts "Row: [$row getName]"
    puts "  Origin: [[$row getOrigin] getX] [[$row getOrigin] getY]"
    puts "  Orientation: [$row getOrient]"
  }

---

## 8. Erreurs courantes et solutions

### Erreur 1 : Site not found

Message :
  ERROR: Site 'core' not found

Solution :
  # Verifier les sites disponibles
  report_lib_cell_sites
  
  # Utiliser le bon nom
  initialize_floorplan -site unithd

### Erreur 2 : Utilization too high

Message :
  WARNING: Utilization 95% exceeds recommended maximum

Solution :
  # Reduire l'utilization
  initialize_floorplan -utilization 75 ...

### Erreur 3 : Core exceeds die

Message :
  ERROR: Core area exceeds die boundaries

Solution :
  # Augmenter core_space
  initialize_floorplan -core_space 150 ...
  
  # Ou definir manuellement
  initialize_floorplan \
      -die_area "0 0 2000 2000" \
      -core_area "100 100 1900 1900"

### Erreur 4 : Invalid aspect ratio

Message :
  ERROR: Aspect ratio 5.0 outside valid range

Solution :
  # Utiliser ratio acceptable (0.5-2.0)
  initialize_floorplan -aspect_ratio 1.5 ...

---

## 9. Bonnes pratiques

1. Toujours verifier avec report_design_area
2. Sauvegarder plusieurs versions (util60.def, util70.def)
3. Documenter les choix dans un fichier log
4. Utiliser des variables pour faciliter l'ajustement
5. Tester plusieurs configurations avant de decider
6. Garder l'utilization < 85%
7. Preferer AR proche de 1.0 sauf contrainte

---

## 10. Script template

Template reutilisable :

  #!/usr/bin/env tclsh
  
  # Configuration
  set design_name "my_design"
  set target_util 70
  set aspect_ratio 1.0
  set core_spacing 100
  
  # Chemins
  set tech_lef "path/to/tech.lef"
  set std_lef "path/to/stdcells.lef"
  set verilog "path/to/design.v"
  
  # Charger design
  read_lef $tech_lef
  read_lef $std_lef
  read_verilog $verilog
  link_design $design_name
  
  # Creer floorplan
  initialize_floorplan \
      -utilization $target_util \
      -aspect_ratio $aspect_ratio \
      -core_space $core_spacing \
      -site core
  
  # Reporter
  report_design_area > reports/floorplan_area.rpt
  report_checks > reports/floorplan_checks.rpt
  
  # Sauvegarder
  write_def results/${design_name}_floorplan.def
  write_db results/${design_name}_floorplan.odb
  
  puts "Floorplan creation completed!"

---

## Ressources

- OpenROAD Documentation : github.com/The-OpenROAD-Project/OpenROAD
- Man page : openroad -help
- Source code : InitFloorplan.cpp

