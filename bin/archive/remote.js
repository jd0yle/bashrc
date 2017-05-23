#!/usr/bin/node
(function(){
    "use strict";
    var cpExec = require("child_process").exec,
        localPath,
        remotePath,
        mountPoints = {
            "web11-qadji.donjohnston.com": "/Users/jdoyle/remote/web11",
            "web12-api.donjohnston.com": "/Users/jdoyle/remote/web12",
            "web13-qangx.donjohnston.com": "/Users/jdoyle/remote/web13",
            "dev-vm": "/Users/jdoyle/remote/dev-bak",
            "dev-jd": "/Users/jdoyle/remote/dev-jd",
            "dev": "/Users/jdoyle/remote/jmdoyle.com"

        };

    if (process.argv[2] !== undefined){
        localPath = process.argv[2];
    } else {
        console.log("ERROR: Requires path to file");
        console.log("ex; remote /var/www/myfile.js");
        throw("invalid args");
    }

    var exec = function(command, callback){
        callback = typeof callback === "function" ? callback : function(){};
        cpExec(command, function(error, stdout, stderr){
            var output;
            if (error){
                throw(error);
            }
            if (stdout !== undefined && stdout !== ""){
                output = stdout;
            }
            if (stderr !== undefined && stderr !== "" && stderr !== "\n"){
                if (output && output !== ""){
                    output += "\n" + stderr;
                } else {
                    output += stderr;
                }
            }
            callback(output);
        });
        return this;
    };

    exec("echo $SSH_CLIENT", function(sshClient){
        var regex = /^(\d+\.\d+\.\d+\.\d+)/g;
        var match = regex.exec(sshClient);
        if (match !== undefined && match !== null && match[1] !== undefined){
            var command,
                mountPoint,
                ip = match[1];
            if (localPath.search(/^\//) !== -1){
                remotePath = localPath;
            } else {
                remotePath = process.cwd() + "/" + localPath;
            }

            mountPoint = mountPoints[require("os").hostname()];
            remotePath = require("path").join(mountPoint, remotePath);
            command = "ssh " + ip + " /usr/local/bin/pstorm " + remotePath;
            exec(command);
        } else {
            console.log("ERROR: Could not find client IP address");
        }
    });

})();