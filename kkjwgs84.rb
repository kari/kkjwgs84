#!/usr/bin/env ruby -w
#
# encoding: utf-8
#
# kkjwgs84.rb 
# @author Kari Silvennoinen
# @version 4
#
# Ruby port of Olli Lammi's KKJWGS84.py (v0.4a), which in turn was originally
# extracted from Viestikallio's PHP source.
#
# Lammi's KKJWGS84.py: http://positio.rista.net/en/pys60gps/ (GPL2, making this port GPL too)
# Viestikallio's kkj-wgs84.php: http://www.viestikallio.fi/tools/kkj-wgs84.php (License not specified)
#
# Copyright (C) 2009  Kari Silvennoinen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
class KKJWGS84

    # Constants
    # Longitude0 and Center meridian of KKJ bands
    KKJ_ZONE_INFO = {	0 => [18.0,  500000.0], 
											1 => [21.0, 1500000.0], 
											2 => [24.0, 2500000.0], 
											3 => [27.0, 3500000.0], 
											4 => [30.0, 4500000.0], 
											5 => [33.0, 5500000.0] }
    
		# Converts a KKJ Northing and Eeasting to WGS84 latitude and longitude
		# @param [Hash] kkj_in KKJ :p and :i
		# @return [Hash] WGS84 :la and :lo
    def kkj_xy_to_wgs84_lalo(kkj_in)  
      kkj_z = kkj_xy_to_kkj_lalo(kkj_in)
      wgs = kkj_lalo_to_wgs84_lalo(kkj_z)
      return wgs
		end
    
		# Converts WGS84 lat and long to KKJ Northing and Eeasting
		# @param [Hash] wgs_in WGS84 :la and :lo
		# @return [Hash] KKJ :p and :i
    def wgs84_lalo_to_kkj_xy(wgs_in)
      kkj_lalo = wgs84_lalo_to_kkj_lalo(wgs_in)
      zone_number = kkj_zone_lo(kkj_lalo[:lo])
      kkj_xy = kkj_lalo_to_kkj_xy(kkj_lalo, zone_number)
			kkj_xy[:p] = kkj_xy[:p].round
			kkj_xy[:i] = kkj_xy[:i].round
      return kkj_xy
		end
    
    # Converts KKJ lat and long to WGS84 lat and long
		# @param [Hash] kkj KKJ :la and :lo
		# @return [Hash] WGS84 :la and :lo
		def kkj_lalo_to_wgs84_lalo(kkj)
      la = kkj[:la]
      lo = kkj[:lo]
      dLa = radians( 0.124867E+01 + 
                    -0.269982E+00 * la + 
                     0.191330E+00 * lo + 
                     0.356119E-02 * la * la + 
                    -0.122312E-02 * la * lo + 
                    -0.335514E-03 * lo * lo ) / 3600.0
      dLo = radians(-0.286111E+02 + 
                     0.114183E+01 * la + 
                    -0.581428E+00 * lo + 
                    -0.152421E-01 * la * la + 
                     0.118177E-01 * la * lo + 
                     0.826646E-03 * lo * lo ) / 3600.0
      wgs = {}
      wgs[:la] = degrees(radians(kkj[:la]) + dLa)
      wgs[:lo] = degrees(radians(kkj[:lo]) + dLo)
      return wgs
		end
    
		# Converts WGS84 lat and long to KKJ lat and long
		# @param [Hash] wgs WGS84 :la and :lo
		# @return [Hash] KKJ :la and :lo
    def wgs84_lalo_to_kkj_lalo(wgs)
      la = wgs[:la]
      lo = wgs[:lo]
      dLa = radians(-0.124766E+01 + 
										 0.269941E+00 * la + 
										-0.191342E+00 * lo + 
										-0.356086E-02 * la * la +
										 0.122353E-02 * la * lo + 
										 0.335456E-03 * lo * lo ) / 3600.0
      dLo = radians( 0.286008E+02 + 
                    -0.114139E+01 * la + 
                     0.581329E+00 * lo + 
                     0.152376E-01 * la * la + 
                    -0.118166E-01 * la * lo + 
                    -0.826201E-03 * lo * lo ) / 3600.0
      kkj = {}
      kkj[:la] = degrees(radians(wgs[:la]) + dLa)
      kkj[:lo] = degrees(radians(wgs[:lo]) + dLo)
      return kkj
		end
    
		# Converts KKJ N/E to KKJ lat and long
		# @param [Hash] kkj KKJ :p and :i
		# @return [Hash] KKJ :la and :lo
    def kkj_xy_to_kkj_lalo(kkj)
      #
      # Scan iteratively the target area, until find matching
      # KKJ coordinate value.  Area is defined with Hayford Ellipsoid.
      #  
      lalo = {}
      zone_number = kkj_zone_i(kkj[:i])
      minla = radians(59.0)
      maxla = radians(70.5)
      minlo = radians(18.5)
      maxlo = radians(32.0)
      i = 1
      while (i < 35)
        deltala = maxla - minla
        deltalo = maxlo - minlo
        lalo[:la] = degrees(minla + 0.5 * deltala)
        lalo[:lo] = degrees(minlo + 0.5 * deltalo)
        kkj_t = kkj_lalo_to_kkj_xy(lalo, zone_number)
        if (kkj_t[:p] < kkj[:p])
          minla = minla + 0.45 * deltala
        else
          maxla = minla + 0.55 * deltala
				end
        if (kkj_t[:i] < kkj[:i]):
          minlo = minlo + 0.45 * deltalo
        else
          maxlo = minlo + 0.55 * deltalo
				end
        i = i + 1
			end
      return lalo
		end
    
		# Converts KKJ lat and long to KKJ N/E
		# @param [Hash] inp KKJ :la and :lo
		# @param [Integer] zone_number KKJ Zone Number
		# @return [Hash] KKJ :p and :i
    def kkj_lalo_to_kkj_xy(inp, zone_number)
      lo = radians(inp[:lo]) - radians(KKJ_ZONE_INFO[zone_number][0])
      a  = 6378388.0            # Hayford ellipsoid
      f  = 1/297.0
      b  = (1.0 - f) * a
      bb = b * b              
      c  = (a / b) * a        
      ee = (a * a - bb) / bb  
      n  = (a - b)/(a + b)     
      nn = n * n              
      cosla = Math.cos(radians(inp[:la]))
      nn2 = ee * cosla * cosla 
      laf = Math.atan(Math.tan(radians(inp[:la])) / Math.cos(lo * Math.sqrt(1 + nn2)))
      coslaf = Math.cos(laf)
      t   = (Math.tan(lo) * coslaf) / Math.sqrt(1 + ee * coslaf * coslaf)
      a0  = a / ( 1 + n )
      a1  = a0 * (1 + nn / 4 + nn * nn / 64)
      a2  = a0 * 1.5 * n * (1 - nn / 8)
      a3  = a0 * 0.9375 * nn * (1 - nn / 4)
      a4  = a0 * 35/48.0 * nn * n
      out = {}
      out[:p] =	a1 * laf - 
									a2 * Math.sin(2 * laf) + 
									a3 * Math.sin(4 * laf) -
                  a4 * Math.sin(6 * laf)
      out[:i] = 	c  * Math.log(t + Math.sqrt(1+t*t)) + 
									500000.0 + zone_number * 1000000.0
      return out
		end
    
    # Determine the KKJ zone number from KKJ easting
		# @param [Numeric] kkj_i KKJ easting
		# @return [Integer] KKJ Zone number
		def kkj_zone_i(kkj_i)
      zone_number = (kkj_i/1000000.0).floor
      if zone_number < 0 or zone_number > 5
        zone_number = -1
			end
      return zone_number
		end
    
    # Determine the KKJ zone number from a KKJ longitude
		# @param [Numeric] kkj_lo KKJ longitude
		# @return [Numeric] Zone number
    def kkj_zone_lo(kkj_lo)
      # determine the zonenumber from KKJ easting
      # takes KKJ zone which has center meridian
      # longitude nearest (in math value) to
      # the given KKJ longitude
      zone_number = 5
      while zone_number >= 0
        if (kkj_lo - KKJ_ZONE_INFO[zone_number][0]).abs <= 1.5:
          break
				end
        zone_number = zone_number - 1
			end
      return zone_number
		end
    
		# Converts radians to degrees
		# @param [Numeric] rad radians
		# @return [Numeric] degrees
    def degrees(rad)
      return rad * 180 / Math::PI
		end
    
		# Converts degrees to radians
		# @param [Numeric] deg degrees
		# @return [Numeric] radians
    def radians(deg)
      return deg * Math::PI / 180
		end
end

if __FILE__ == $0
	require "pp"
  k = KKJWGS84.new
  test = {}
  test[:la] = 60.00
  test[:lo] = 25.00
  pp k.wgs84_lalo_to_kkj_xy(test)
	test[:p] = 6654634
	test[:i] = 2555976
	pp k.kkj_xy_to_wgs84_lalo(test)
end