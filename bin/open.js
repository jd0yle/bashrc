#!/usr/bin/node
(function(){
    "use strict";
    var cpExec = require("child_process").exec,
        scriptName = require("path").basename(process.argv[1]),
        localPath = "",
        remotePath = "",
        mountPoint = "",
        mountPoints = {
            "web11-qadji.donjohnston.com": "/Users/jdoyle/remote/web11",
            "web12-api.donjohnston.com": "/Users/jdoyle/remote/web12",
            "web13-qangx.donjohnston.com": "/Users/jdoyle/remote/web13",
            "dev-vm": "/Users/jdoyle/remote/dev-bak",
            "dev-jd": "/Users/jdoyle/remote/dev-jd"

        };

    if (process.argv[2] !== undefined){
        localPath = process.argv[2];
    } else {
        console.log("ERROR: Requires path to file");
        console.log("ex; remote /var/www/myfile.js");
        throw("invalid args");
    }

    if (process.argv[3] !== undefined){
        remotePath = process.argv[3];
    }

    var exec = function(command, callback){
        callback = typeof callback === "function" ? callback : function(){};
        cpExec(command, function(error, stdout, stderr){
            var output;
            if (error){
                console.log(command);
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

    var getClientIp = function(callback){
        exec("echo $SSH_CLIENT", function(sshClient){
            var regex = /^(\d+\.\d+\.\d+\.\d+)/g;
            var match = regex.exec(sshClient);
            if (match !== undefined && match !== null && match[1] !== undefined){
                callback(match[1]);
            } else {
                callback(undefined);
            }
        });
    };

    /*exec("echo $SSH_CLIENT", function(sshClient){
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
    });*/



    getClientIp(function(clientIp){
        var command;
        if (clientIp === undefined){ // We're on the source of all the ssh connections
            if (remotePath === undefined || remotePath === ""){
                console.log("remotePath undefined...");
                process.exit(1);
            } else {
                command = "/usr/local/bin/pstorm " + remotePath;
                exec(command);
            }
        } else {
            if (remotePath === undefined || remotePath === ""){
                if (localPath.search(/^\//) !== -1){
                    remotePath = localPath;
                } else {
                    remotePath = process.cwd() + "/" + localPath;
                }
                mountPoint = mountPoints[require("os").hostname()];
                if (mountPoint === undefined || mountPoint === ""){
                    console.log("ERROR: Could not find mount point for " + require("os").hostname());
                    process.exit(2);
                }
                remotePath = require("path").join(mountPoint, remotePath);
                //command = "ssh " + clientIp + " /home/jdoyle/.prompt/" + scriptName + " " + remotePath;
                command = "ssh " + clientIp + " \"source ~/.bashrc;sh ~/.prompt/remote.js " + remotePath + "\"";
                exec(command);
            } else {
                command = "ssh " + clientIp + " source ~/.bashrc;sh ~/.prompt/remote.js " + remotePath + " " + remotePath;
                exec(command);
            }
        }
    });

})();