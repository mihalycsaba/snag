// Copyright (C) 2025 Mihaly Csaba
//
// This file is part of Snag.
//
// Snag is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Snag is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Snag.  If not, see <https://www.gnu.org/licenses/>.

class GiveawayFilterModel {
  String search;
  String minLevel;
  String maxLevel;
  String minEntries;
  String maxEntries;
  String minPoints;
  String maxPoints;
  String minCopies;
  String maxCopies;
  bool hideEntered;
  bool onlyRegionRestricted;
  GiveawayFilterModel(
      {this.search = '',
      this.minLevel = '',
      this.maxLevel = '',
      this.minEntries = '',
      this.maxEntries = '',
      this.minPoints = '',
      this.maxPoints = '',
      this.minCopies = '',
      this.maxCopies = '',
      this.hideEntered = false,
      this.onlyRegionRestricted = false});

  @override
  bool operator ==(covariant GiveawayFilterModel other) {
    if (identical(this, other)) return true;

    return other.search == search &&
        other.minLevel == minLevel &&
        other.maxLevel == maxLevel &&
        other.minEntries == minEntries &&
        other.maxEntries == maxEntries &&
        other.minPoints == minPoints &&
        other.maxPoints == maxPoints &&
        other.minCopies == minCopies &&
        other.maxCopies == maxCopies &&
        other.hideEntered == hideEntered &&
        other.onlyRegionRestricted == onlyRegionRestricted;
  }

  @override
  int get hashCode {
    return search.hashCode ^
        minLevel.hashCode ^
        maxLevel.hashCode ^
        minEntries.hashCode ^
        maxEntries.hashCode ^
        minPoints.hashCode ^
        maxPoints.hashCode ^
        minCopies.hashCode ^
        maxCopies.hashCode ^
        hideEntered.hashCode ^
        onlyRegionRestricted.hashCode;
  }
}
