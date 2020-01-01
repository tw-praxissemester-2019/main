<?php
    ### author: twilts
    ### purpose: rest api for classification by spark model.
    header('Access-Control-Allow-Origin: *');
    $method = $_SERVER['REQUEST_METHOD'];
    $request = explode('/',trim($_SERVER['PATH_INFO'],'/'));

    switch($request[0]) {
        case 'classify' : {
            ### get the grid values for the location and pass it to the classification
            $grid_out = shell_exec('python /scripts/get_grid_value.py '.$request[1].' '.$request[2].' '.$request[3]);
            $output = shell_exec("python /scripts/classify.py '".$grid_out."'");
            echo str_replace("None","\"None\"",str_replace("'","\"",$output));
            break;
        }
        case 'check' : {
            ### to check if the api is reachable
            echo $request[1];
            break;
        }
        default : {
	    echo "sorry, this is not a valid endpoint.";
            break;
        }
    }
?>