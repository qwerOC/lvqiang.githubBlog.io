### FMDB事务的使用
>1 创建数据库

```
 FMDatabaseQueue *queue;
-(void)creatTableList{
	    //1.获得数据库文件的路径
    NSArray  * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES );
    NSString  * documentDirectory = [path    objectAtIndex :0 ];
    NSString *fileName = [documentDirectory stringByAppendingPathComponent:@"t_user.sqlite"];
	  [queue inDatabase:^(FMDatabase *db) {
        //创建数据表
        BOOL flag = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_user (id integer PRIMARY KEY AUTOINCREMENT, imageobject text, otherObject text,currttentStates text)"];
        if (flag) {
            NSLog(@"表创建成功");
        } else {
            NSLog(@"表创建失败");
        }
    }];
	
}
```
>2 查询数据库

```
-(NSMutableArray *)searchList{
	  NSMutableArray*dataArray = [[NSMutableArray alloc]init];
	      [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM t_user"];
        
            while(result.next) {
        
                    //创建对象赋值
        
                    MuUpload2* load2 = [[MuUpload2 alloc]init];
        
                    load2.imageobject= [result stringForColumn:@"imageobject"];
        
                    load2.otherObject= [result stringForColumn:@"otherObject"];
        
                    load2.currttentStates=[result stringForColumn:@"currttentStates"];
        
                    [dataArray addObject:load2];
        
                }
    }];
    return dataArray;
	
	
}
```

>3 添加方法


```
-(void)addUser:(MuUpload2 *)upload2{
   NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO  t_user ('imageobject','otherObject','currttentStates') VALUES ('%@', '%@','%@')",upload2.imageobject,upload2.otherObject,upload2.currttentStates];
       [queue inDatabase:^(FMDatabase *db) {
                BOOL flag = [db executeUpdate:sqlStr];
                if (flag) {
                    NSLog(@"数据添加成功");
                } else {
                    NSLog(@"数据添加失败");
                }
            }];

}
```


>3 删除方法

```
-(void)Deluser:(MuUpload2 *)upload2{
	  NSString*sqlStr = [NSString stringWithFormat:@"DELETE FROM t_user  WHERE imageobject = '%@' ",upload2.imageobject];
	    [queue inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:sqlStr];
        if (flag) {
            NSLog(@"数据删除成功");
        } else {
            NSLog(@"数据删除失败");
        }
    }];

}
```

>4 更新方法

```
-(void)Update:(MuUpload2 *)upload2{

	NSString*sqlStr = [NSString stringWithFormat:@"UPDATE t_user SET currttentStates = '%@'  WHERE imageobject = '%@'",upload2.currttentStates,upload2.imageobject];
        [queue inDatabase:^(FMDatabase *db) {
        
                //开启事务
                [db beginTransaction];
                BOOL flag = [db executeUpdate:sqlStr];
                if (flag) {
                    NSLog(@"数据更新成功");
                } else {
                    NSLog(@"数据更新失败");
                    //事务回滚
                    [db rollback];
                }
                //提交事务
                [db commit];
            }];
}
```


> 5 删除数据库

```
-(void)delTable{
	    [queue inDatabase:^(FMDatabase *db) {
        BOOL flag = [db executeUpdate:@"DROP TABLE IF EXISTS T_USER"];
        if (flag) {
            NSLog(@"数据表删除成功");
        } else {
            NSLog(@"数据表删除失败");
        }
    }];
}
```

