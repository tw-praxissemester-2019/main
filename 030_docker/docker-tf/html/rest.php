<?php
    ### author: twilts
    ### purpose: rest api for training, classification and check the tensorflow model.
    header('Access-Control-Allow-Origin: *');
    $method = $_SERVER['REQUEST_METHOD'];
    $request = explode('/',trim($_SERVER['PATH_INFO'],'/'));

    switch($request[0]) {
        case 'train' : {
            $ip = shell_exec('cat /data/ip');
            $output = shell_exec('python /data/train.py '.$ip);
            echo $output;
            break;
        }
        case 'classify' : {
            $ip = shell_exec('cat /data/tfs_ip');
            $grid_out = shell_exec('python /data/get_grid_value.py '.$request[1].' '.$request[2].' '.$request[3]);
            $output = shell_exec("python /data/req.py '".$ip."' '".$grid_out."'");
            echo $output;
            break;
        }
        case 'check' : {
            echo $request[0];
            break;
        }
        default : {
            echo "sorry, this is not a valid endpoint.";
            break;
        }
    }
?>