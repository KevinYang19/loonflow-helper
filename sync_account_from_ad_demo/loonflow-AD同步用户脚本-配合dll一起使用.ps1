#ʹ�ý̳�
#�ҵ�MySql.Data.dll��·��������ļ���

$dll_path = "C:\powershell\dll\mysql\v4.5\MySql.Data.dll"  #dll·��
$mysql_ip = "10.10.3.51"   #ʵ��loonflow�ķ�����IP
$mysql_port = "3306"       #�˿� ��Ĭ����3306
$mysql_account = "root"    #�˺�Ĭ����root
$mysql_paassword = "Liu@2019"   #����
$mysql_database_name = "loonflow"   #ʵ�����ƣ�Ĭ����loonflow
$ou_path = "dc=test,dc=com"    #��Ҫͬ����OU·��

#-----------------------------------------------------�½������û�����-��ʼ---------------------------------------------------------------------------------------
function mysql-insert-loonflow-user($f_username,$f_alias,$f_email,$f_phone,$f_password,$dept_id,$is_active,$is_admin,$creator,$is_deleted,$gmt_created,$gmt_modified)
    {
        [void][system.Reflection.Assembly]::LoadFrom($dll_path)
        #����mysql���
        $connectionString = "server=$mysql_ip;uid=$mysql_account;pwd=$mysql_paassword;database=$mysql_database_name;charset='utf8';port=$mysql_port"   #����������Ϣ
        $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)   #�½�����
        $connection.Open()                                                                   #�����ݿ�
        $insertsql = "SELECT * from account_loonuser where username='$f_username'"           #��ѯsql������Ϊ�����û���
        Write-Host $insertsql                                                                #��ӡsql��䷽���Ŵ�
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($insertsql, $connectionString)    
        $dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)         
        $dataSet = New-Object System.Data.DataSet                                                                              
        $recordCount = $dataAdapter.Fill($dataSet, "data")                                  #��ȡ����ѯ��Ľ�������浽1������ 
        if ([int]($dataSet.Tables["data"].username).Length -ge '1')     #����ѯ��Ŀ���ڵ���1ʱ���ж��û��Ѵ���
            {
            return $f_username+"    �Ѵ���"  #����ж�������Ѵ��ڣ�����Ļ
            }
        else                                 #�����ִ���½�����
            {
            #����mysql���
            $insertsql= "INSERT INTO account_loonuser(username,alias,email,phone,password,dept_id,is_active,is_admin,creator,is_deleted,gmt_created,gmt_modified) VALUES('$f_username','$f_alias','$f_email','$f_phone','$f_password','$dept_id','$is_active','$is_admin','$creator','$is_deleted','$gmt_created','$gmt_modified');" 
            #���������뵽��Ӧmysql�ֶ�
            $insertcommand = New-Object MySql.Data.MySqlClient.MySqlCommand 
            $insertcommand.Connection=$connection 
            $insertcommand.CommandText=$insertsql 
            $insertcommand.ExecuteNonQuery()   #�ύmysql�����
            $connection.Close()    
            return $f_username+"  �½���Ϣ�ɹ�"   #�����½��ɹ�����Ϣ
            }
     $connection.Close()   #�ر�sql
    }
#-----------------------------------------------------�½������û�����-����---------------------------------------------------------------------------------------

$aduser_all = Get-ADUser -SearchBase $ou_path -Filter * -Properties *   #��ȡָ��OU����������û�
foreach ($aduser in $aduser_all)                                        #ѭ��ÿ1���û�
    {
    $dept_id = [int](($aduser.objectSid).Value -split "-")[-1]   #��ȡ1��ΨһID
    $date = (get-date).ToString('yyyy-MM-dd HH;MM;ss')           #���嵱ǰʱ�䣬����ʽ��

    mysql-insert-loonflow-user -f_username $aduser.SamAccountName -f_alias $aduser.DisplayName -f_email $aduser.UserPrincipalName -f_phone 18888888888 -f_password loonflow@2019 -dept_id $dept_id -is_active 1 -is_admin 0 -creator "����ƻ�" -is_deleted 0 -gmt_created $date -gmt_modified $date
    #ִ�к����������û���loonflow�����������д�ģ��������ܵ�½
    }