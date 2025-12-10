#!/usr/bin/env python3
"""
Visualisation des 3 floorplans
Genere un graphique comparatif
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Donnees des floorplans (a ajuster selon resultats)
floorplans = {
    'AR=0.5': {'width': 600, 'height': 1200, 'rows': 441, 'util': 69.8, 'color': 'lightblue'},
    'AR=1.0': {'width': 845, 'height': 845, 'rows': 311, 'util': 70.0, 'color': 'lightgreen'},
    'AR=2.0': {'width': 1200, 'height': 600, 'rows': 221, 'util': 69.4, 'color': 'lightcoral'},
}

# Creer figure avec subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Aspect Ratio Comparison - 500K um² Design @ 70% Util', fontsize=16, fontweight='bold')

# Subplot 1: Floorplan shapes
ax1 = axes[0, 0]
ax1.set_title('Floorplan Shapes (with 100um margin)', fontsize=12, fontweight='bold')
ax1.set_xlabel('Width (um)')
ax1.set_ylabel('Height (um)')
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

y_offset = 0
max_width = 0

for name, data in floorplans.items():
    w = data['width']
    h = data['height']
    
    # Die (avec marge)
    die_w = w + 200  # marge de 100 de chaque cote
    die_h = h + 200
    
    die_rect = patches.Rectangle((0, y_offset), die_w, die_h, 
                                   linewidth=2, edgecolor='black', 
                                   facecolor='lightgray', alpha=0.3)
    ax1.add_patch(die_rect)
    
    # Core
    core_rect = patches.Rectangle((100, y_offset + 100), w, h,
                                    linewidth=2, edgecolor='darkblue',
                                    facecolor=data['color'], alpha=0.7)
    ax1.add_patch(core_rect)
    
    # Label
    ax1.text(die_w/2, y_offset + die_h + 50, name, 
             ha='center', fontsize=10, fontweight='bold')
    ax1.text(die_w/2, y_offset + die_h + 20, 
             f"{w:.0f}x{h:.0f}um, {data['rows']} rows",
             ha='center', fontsize=8)
    
    y_offset += die_h + 150
    max_width = max(max_width, die_w)

ax1.set_xlim(-50, max_width + 50)
ax1.set_ylim(-100, y_offset)

# Subplot 2: Number of rows
ax2 = axes[0, 1]
ax2.set_title('Number of Rows', fontsize=12, fontweight='bold')
names = list(floorplans.keys())
rows = [floorplans[n]['rows'] for n in names]
colors = [floorplans[n]['color'] for n in names]

bars = ax2.bar(names, rows, color=colors, edgecolor='black', linewidth=2)
ax2.set_ylabel('Number of Rows')
ax2.grid(True, axis='y', alpha=0.3)

for bar, row in zip(bars, rows):
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width()/2., height + 5,
             f'{row}', ha='center', va='bottom', fontweight='bold')

# Subplot 3: Utilization
ax3 = axes[1, 0]
ax3.set_title('Core Utilization', fontsize=12, fontweight='bold')
utils = [floorplans[n]['util'] for n in names]

bars = ax3.bar(names, utils, color=colors, edgecolor='black', linewidth=2)
ax3.set_ylabel('Utilization (%)')
ax3.set_ylim(68, 71)
ax3.axhline(y=70, color='red', linestyle='--', linewidth=2, label='Target: 70%')
ax3.legend()
ax3.grid(True, axis='y', alpha=0.3)

for bar, util in zip(bars, utils):
    height = bar.get_height()
    ax3.text(bar.get_x() + bar.get_width()/2., height + 0.1,
             f'{util:.1f}%', ha='center', va='bottom', fontweight='bold')

# Subplot 4: Die area
ax4 = axes[1, 1]
ax4.set_title('Total Die Area', fontsize=12, fontweight='bold')

die_areas = []
for name, data in floorplans.items():
    die_w = data['width'] + 200
    die_h = data['height'] + 200
    die_areas.append(die_w * die_h / 1e6)  # Convert to mm²

bars = ax4.bar(names, die_areas, color=colors, edgecolor='black', linewidth=2)
ax4.set_ylabel('Die Area (mm²)')
ax4.grid(True, axis='y', alpha=0.3)

for bar, area in zip(bars, die_areas):
    height = bar.get_height()
    ax4.text(bar.get_x() + bar.get_width()/2., height + 0.02,
             f'{area:.3f}', ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('aspect_ratio_comparison.png', dpi=300, bbox_inches='tight')
print("Saved: aspect_ratio_comparison.png")
plt.show()

