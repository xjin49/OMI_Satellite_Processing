
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    

;----------------------------------------------------------------------


begin
   netCDF = True

do year = 2012, 2013

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
   diro   = "./HCHO_Daily/"                  ; netCDF file directory

   mlon   = 1440
   nlat   = 720


   xi     = new((/nlat,mlon/), "float", 999)

 ;  print(nf)
 
 if (isfilepresent(HCHOFile))
      head = readAsciiHead(HCHOFile, 6)
   ;  print(head)             ; print first 11 lines (arbitrary)

  xi = readAsciiTable(HCHOFile,mlon,"float",6)
    
;---Add attributes and coordinates

     xi@long_name = "HCHO_Daily"

    
  ; lat   = latGlobeFo(nlat,"lat","latitude","degrees_north")
  ; lon   = lonGlobeFo(mlon,"lon","longitude","degrees_east")
  ; lon   = (/ lon - 180. /)  ; subtract 180 from all values 
  ; lon&lon = lon 
   
   lat = fspan(-89.88, 89.88, nlat)
   lat@units = "degrees_north"
   lon = fspan(0.12, 359.88, mlon)
   lon   = (/ lon - 180. /)  ; subtract 180 from all values 
   lon@units = "degrees_east"
     
 ;    time         = ispan(1,nfils,1)
  
     xi!0   = "lat"
     xi!1   = "lon"
  ;   xi!2   = "time"
     xi&lat =  lat
     xi&lon =  lon
   ;  xi&time = time


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

       ncdf->HCHO = xi
     end if 
 delete(xi)
 end if    
end do
end do

end