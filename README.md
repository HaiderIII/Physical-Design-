# OpenSTA Resources

## Fichiers
- simple_inv.v/sdc : Inverseur
- pipeline_reg.v/sdc : Pipeline 4-bit
- adder8.v/sdc : Additionneur 8-bit
- hier_design.v : Design hierarchique
- simple.lib : Liberty library
- sta_template.tcl : Script template

## Usage
sta -f sta_template.tcl

## 🐳 Utilisation avec Docker

### Prérequis
- Docker installé
- ~3 GB d'espace disque

### Installation
```bash
# 1. Cloner le projet
git clone https://github.com/ton-compte/Physical-Design.git
cd Physical-Design

# 2. Télécharger l'image OpenROAD
docker pull theopenroadproject/openroad:latest

# 3. Tester
./docker/run.sh openroad -version
cd ~/projects/Physical-Design

cat >> .gitignore << 'EOF'

# ==============================================================================
# DOCKER
# ==============================================================================
docker/volumes/
docker/.env.local
