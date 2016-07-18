//
//  Schema.m
//  MapSpot
//
//  Created by DetroitLabs on 7/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/*


{
 
    "spots": {
        "one": {
            "createdAt": 07/03/14,
            "lat": 42.2233,
            "long": -82.9999,
            "message": Hello,
            "userID": 12345,
            "username": donovan_cotter
            "photos": {photo1: true, photo2: true, photo3: true}
            "videos": {video1: true, video2: true, video3: true}
            "comments": {Mk89-KLUT2SJjS: true, TAk-987KlOpSAW67: true, GAk-987KlOpSAW227: true, JA526SJJ9299K02-H: true} //These will be the IDs for the comments. Comments will be their own object. These are comments people post to the spots.
        },
 
        "two": {...},
        "three": {...},
        "four": {...}
    }
 
    "users": {
        "User1": {
             "username": donovan_cotter,
             "fullName": Donovan Cotter,
             "bio": Hello, I'm an iOS developer,
             "email": donovan@gmail.com,
             "DOB": 12/08/1987,
             "location": Detroit, MI,
             "userId": 12345
             "profilePhotoDownloadURL": htps:profilephoto//212
             "backgroundProfilePhotoDownloadURL": htps:profilephoto//212
             "spots": {spot1: true, spot2: true}
        },
 
        "User2": {....},
        "User3": {....},
    }
 
    "photos": {
 
        "Photo1": {
             "photoURL": htps://photo13252522
             "timestamp": 01/01/2016 4:30 PM
             "size": 100 x 100
             "contentType": image/JPEG
        },
 
        "Photo2": {....},
        "Photo3": {....}
    }
 
     "videos": {
     
         "Video1": {
             "videoURL": htps://photo13252522
             "timestamp": 01/01/2016 4:30 PM
             "size": 100 x 100
             "contentType": image/JPEG
         },
 
         "Video2": {....},
         "Video3": {....}
     }
 
     "comments": {
         "comment1": {
             "username": donovan_cotter,
             "userId": 12345
             "comment": Hello, this is a comment.
             "spotOwner": spot1
         },
         
         "comment2": {....},
         "comment3": {....},
     }
 
 }


*NoSQL database: https://www.airpair.com/firebase/posts/structuring-your-firebase-data
 
 
*WHEN WE HAVE A DATA STRUCTURE LIKE THIS WE MUST REMEBER:
    -With this kind of structure, you should keep in mind to update the data at 2 locations
 
    -everywhere on the Internet, the object keys are written like "user1","group1","group2" etc.
    where as in practical scenarios it is better to use firebase generated keys which look like '-JglJnGDXcqLq6m844pZ'.
    We should use these as it will facilitate ordering and sorting.
 
    -






























*/