
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

;-----------NCL script used to convert TEMIS ASCII data to NetCDF format------
;-----------Author: Xiaomeng Jin---------
;-----------Last Update: Feb 3, 2018-----


begin

yearstrt = 2012 ; Starting year
yearend =  2013 ; Ending year

   netCDF = True

do year = yearstrt, yearend

 if (mod(year,4).eq.0) then 
 nday = 366
 else
 nday = 365
 end if
   
 juld = toint(greg2jul(year,1,1,0)+0.5)
do idate= juld, juld+nday-1

  gregdate = jul2greg(idate)
  stryear = tostring(gregdate(0))
  strmon = tostring(gregdate(1))
  if (gregdate(1).lt.10) then
  strmon = "0"+strmon
  end if 
  strday = tostring(gregdate(2))
  if (gregdate(2).lt.10) then
  strday = "0"+strday
  end if      

   HCHOFile   = "./TEMIS_Data/OMIH2CO_Grid_720x1440_"+stryear+strmon+strday+".dat"                  ; input directory with data

print(HCHOFile)
   diro   = "./HCHO_Daily/"                  ; Output netCDF file directory

   mlon   = 1440
   nlat   = 720

   HCHO_i     = new((/nlat,mlon/), "float", 999)
 
 if (isfilepresent(HCHOFile))
      head = readAsciiHead(HCHOFile, 6)
   ;  print(head)             ; print first 11 lines (arbitrary)

  HCHO_i = readAsciiTable(HCHOFile,mlon,"float",6)
    
;---Add attributes and coordinates

     HCHO_i@long_name = "HCHO_Daily"
   
   lat = fspan(-89.88, 89.88, nlat)
   lat@units = "degrees_north"
   lon = fspan(0.12, 359.88, mlon)
   lon   = (/ lon - 180. /)  ; subtract 180 from all values 
   lon@units = "degrees_east"
       
     HCHO_i!0   = "lat"
     HCHO_i!1   = "lon"
     HCHO_i&lat =  lat
     HCHO_i&lon =  lon


     sfx    = get_file_suffix(HCHOFile, 0)
     fnam   = sfx@fBase

 
;---Write to NetCDF file
     if (netCDF) then
       
       fout    = diro+"OMI_HCHO_"+stryear+strmon+strday+".nc"

      system("/bin/rm -f "+fout)       ; remove any pre-existing file
      ncdf    = addfile(fout ,"c")     ; open output netCDF file

       fAtt               = True             ; assign file attributes
       fAtt@title         = "HCHO_Daily"  
       fAtt@Conventions   = "None"   
    ;   fAtt@creation_date = systemfunc ("date")        
       fileattdef( ncdf, fAtt )              ; copy file attributes    

       ncdf->HCHO = HCHO_i
     end if 
 delete(HCHO_i)
 end if    
end do
end do

end