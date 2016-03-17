#!/usr/bin/env node
/**
 * cb.js
 * Copies the text provided by stdin while SSHed into a remote host to local host's clipboard
 * Project: .prompt
 * Description:
 * Creator: Justin Doyle <jdoyle@donjohnston.com>
 * Date: 12/16/2015
 */

(function () {
    "use strict";
    var cpExec = require("child_process").exec;
    var stdin = process.openStdin(),
        data = "";

    var exec = function (command, callback) {
        callback = typeof callback === 'function' ? callback : function () {};
        cpExec(command, function (error, stdout, stderr) {
            var output;
            if (error) {
                throw(error);
            }
            if (stdout !== undefined && stdout !== "") {
                output = stdout;
            }
            if (stderr !== undefined && stderr !== "" && stderr !== "\n") {
                if (output && output !== "") {
                    output += "\n" + stderr;
                } else {
                    output += stderr;
                }
            }
            callback(output);
        });
        return this;
    };

    var getClientIp = function (callback) {
        exec("echo $SSH_CLIENT", function (sshClient) {
            var regex = /^(\d+\.\d+\.\d+\.\d+)/g;
            var match = regex.exec(sshClient);
            if (match !== undefined && match !== null && match[1] !== undefined) {
                var ip = match[1];
                callback(ip);
            } else {
                callback(undefined);
            }
        });
    };

    stdin.on('data', function (chunk) {
        data += chunk;
    });

    stdin.on('end', function () {
        getClientIp(function (ip) {
            var command;
            if (!ip) {
                console.log("Client IP address could not be found.");
                process.exit(-1);
            }
            command = "echo \"" + data + "\" | ssh " + ip + " pbcopy ";
            exec(command, function () {
                process.exit(0);
            });
        });
    });
})();
