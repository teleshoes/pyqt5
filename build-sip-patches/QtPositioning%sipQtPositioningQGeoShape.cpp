*** QtPositioning/sipQtPositioningQGeoShape.cpp	2022-01-23 13:52:05.751413148 -0500
--- QtPositioning/sipQtPositioningQGeoShape.cpp	2022-01-23 15:34:30.237572369 -0500
***************
*** 185,193 ****
          {
               ::QGeoCoordinate*sipRes;
  
!             sipRes = new  ::QGeoCoordinate(sipCpp->center());
! 
!             return sipConvertFromNewType(sipRes,sipType_QGeoCoordinate,NULL);
          }
      }
  
--- 185,191 ----
          {
               ::QGeoCoordinate*sipRes;
  
!             return sipConvertFromNewType(NULL,sipType_QGeoCoordinate,NULL);
          }
      }
  
