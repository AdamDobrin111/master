//
//  UrlEndPoints.swift
//  Emeritus
//
//  Created by SB on 22/12/14.
//  Copyright (c) 2016 Emeritus Institute of Management Pte. Ltd. All rights reserved.
//

import Foundation

//TODO - these URLs should be made configurable and picked up from a config file.

//Base Url.
let baseUrl : String = "http://52.22.22.151:8080/api"
let baseLocalUrl : String = "http://52.22.22.151:8080/api"

//POST method End Urls.
let loginEndPoint : String = "/general/login"
let searchEndPoint : String = "/api/search"
let confirmationCodeEndPoint : String = "/general/confirmationCode"
let createNewPasswordCodeEndPoint : String = "/general/changePassword"

//GET method End Urls.
let getProfileEndPoint : String = "/api/profile"