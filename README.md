# Flutter Image Picker

## 1. 背景
想通过一个图片选择器，来上手Flutter开发，关于Android开发者如何上手Flutter开发，这边强力推荐官方的链接：[Flutter For Android Developer](https://flutter.dev/docs/get-started/flutter-for/android-devs)，里面详细把Android相关的知识点与Flutter对应起来，是入门的好材料。

## 2. 功能介绍（仅Android端）
* [x] 支持浏览本机图片
* [x] 支持查看大图
* [x] 支持左右滑动浏览大图
* [x] 支持选中图片，并且最多限制9张
* [x] 支持查看仅查看已选中的图片

![flutter_image_picker](https://raw.githubusercontent.com/chaojian/image_picker/master/flutter_image_picker.gif)

## 3. 步骤
（1）如何获取到本机的图片
在Android开发者的角度，获取图片，就是通过ContentResolver查询数据库，获取到所有的图片路径。那么Flutter应该怎么操作呢？简单的说，Flutter其实就是在于UI的复用，但是如果涉及到平台相关的功能，还是需要写对应平台的Plugin与平台进行通讯。Flutter提供了一种方式，就是通过MethodChannel来进行与平台相关接口的通讯，如下：

```
class _MainPageState extends State<MainPage> {
// 定义一个Channel，用于访问平台相关的                                  
  static const platform = MethodChannel("com.lichaojian.image_picker/Media");   
  List imageList;                                                               
  final mSelectedImages = new Set<String>();

  @override                                                                     
  void initState() {                                                            
    super.initState();                                                          
    getImages();                                                                
  }

// 获取图片
  void getImages() async {                                                      
    List result;                                                                
    try {    
    // 这里就是获取到所有图片路径的逻辑，通过调用MethodChannel的getImages的方法获取所有的图片                                                                   
      result = await platform.invokeMethod('getImages');                        
    } on PlatformException catch (e) {                                          
      log("PlatformException Message ${e.message}");                            
    }                                                                           
    setState(() {                                                               
      imageList = result;                                                       
    });                                                                         
  }

  @override                                                                     
  Widget build(BuildContext context) {                                          
    return new Scaffold(                                                        
      appBar: AppBar(                                                           
        title: Text("Image Picker"),                                            
        actions: <Widget>[buildConfirmButton()],                                
      ),                                                                         

```
上面的代码简述了，在Flutter侧通过MethodChannel的getImages的方法来获取图片，那么这个方法是从哪里进行定义的呢，由于本人是一个Android开发者，所以在这里只阐述怎么定义一个Android的Plugin来与Flutter进行通讯，如下代码：

```
// 在Android端定义一个Plugin，实现MethodChannel.MethodCallHandler, 复写onMethodCall的方法
class MediaPlugin(flutterActivity: FlutterActivity) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "MediaPlugin"
        private const val CHANNEL = "com.lichaojian.image_picker/Media"
        private const val GET_IMAGES = "getImages"

        // 此处需要在FlutterActivity中注册进来
        fun registerMediaPlugin(flutterActivity: FlutterActivity) {
        // Android端创建MethodChannel对象，需要注意的是，这里定义的MethodChannle的名字需要保持与Flutter一致，为了避免冲突，一般是官方推荐使用的是包名+功能            val methodChannel = MethodChannel(flutterActivity.flutterView, CHANNEL)
            methodChannel.setMethodCallHandler(MediaPlugin(flutterActivity))
        }
    }

    private var mFlutterActivity = flutterActivity
    private val mImageList  = ArrayList<String>(6000)

// 当Flutter侧调用平台相关的方法，就会回调到该方法当中
    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            // 这里就是刚才Flutter调用的getImages方法
            GET_IMAGES -> {
                getImages(result)
            }
            else -> {
                Log.i(TAG, "can't find the method ${methodCall.method}")
                result.notImplemented()
            }
        }
    }

// 这个方法实际上就是通过查询contentResolver来获取到所有的图片的路径。
    private fun getImages(result: MethodChannel.Result) {
        val imageUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val contentResolver: ContentResolver = mFlutterActivity.contentResolver
        val projection = arrayOf(
            MediaStore.Images.ImageColumns.DATA, MediaStore.Images.ImageColumns.DISPLAY_NAME,
            MediaStore.Images.ImageColumns.SIZE, MediaStore.Images.ImageColumns.DATE_ADDED
        )
        val cursor = contentResolver.query(imageUri, projection, null, null, MediaStore.Images.Media.DATE_ADDED + " desc")
        if (cursor == null) {
            result.error("UNAVAILABLE", "get photos error.", null)
            return
        } else {
            while (cursor.moveToNext()) {
                val path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA))
                mImageList.add(path)
            }
            cursor.close()
            result.success(mImageList)
        }
    }
}
```

在MainActivity继承FlutterActivity中对Plugin进行注册


```
class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 注册上面编写的MediaPlugin
        MediaPlugin.registerMediaPlugin(this)
    }
}
```

（2）让图片显示出来
获取到本机的所有的图片的时候，这时候，就应该考虑到怎么让图片显示出来，我这里用的是GridView的方式显示，在Flutter当中，创建并且使用一个GridView，可以说是非常的便捷的：


```
// Flutter 中如何创建一个GridView
Widget getGridView() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: imageList.length, //返回GridView的Item的数量
      padding: EdgeInsets.all(10), // 让GridView上下左右都有10个像素的padding
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,// 每一行有多少个Item
          mainAxisSpacing: 3, // 行距
          crossAxisSpacing: 3,// 列距
          childAspectRatio: 1.0// 缩放倍数，一般为1),
      itemBuilder: (context, index) {
        return buildItem(index);//这里是构建GridView的Item
      },
    );
  }
```

创建GridView的Item，因为这里面，我引入了一些其他的逻辑，例如加入勾选按钮，限制选择的数量为9张等，实际上也是相对简单的。

```
Widget buildItem(int index) {
    String imagePath = imageList[index];
    bool alreadySelected = mSelectedImages.contains(imagePath);

    return new GestureDetector( //为了让Item支持点击事件，所以包裹了GestureDetector
      child: Stack( // 这里用Stack，为了达到View的覆盖效果，类似于Android当中我们常用的RelativeLayout
        children: <Widget>[
          new ClipRRect(
            borderRadius: BorderRadius.circular(3),
            // 这里是真正加载图片的地方，就这么一句话就可以完成图片的加载
            child: Image.file(File(imagePath),
                width: 200, height: 200, cacheWidth: 200, cacheHeight: 200),
          ),
          // 放在左下方的勾选框
          new Align(
            alignment: Alignment.bottomRight,
            child: Checkbox(
              value: alreadySelected,
              onChanged: (newValue) {
                if (mSelectedImages.length == 9 && !alreadySelected) {
                  Fluttertoast.showToast(
                      msg: "你最多只能选择9张图片",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  return;
                }
                setState(() {
                  if (alreadySelected) {
                    mSelectedImages.remove(imagePath);
                  } else {
                    mSelectedImages.add(imagePath);
                  }

                  alreadySelected = newValue;
                });
              },
              autofocus: false,
              tristate: true,
              activeColor: Colors.blueGrey,
              checkColor: Colors.green,
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          )
        ],
      ),
      // Item的点击事件
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return BrowseImagesPage(index, imageList);
        }));
      },
    );
```
（3）页面跳转
看（2）中的点击事件，可以看出点击事件，是怎么回事，Flutter当中的页面跳转，可以用Navigator and Routes来实现页面跳转，效果跟Activity是一致的，代码如下：


```
Navigator.push(context, MaterialPageRoute(builder: (_) {
          return BrowseImagesPage(index, imageList);

```

（4）滑动浏览图片
作为一个Android开发者，滑动浏览图片，我们最先应该是想到类似我们Banner一样用到的ViewPage，在Flutter当中，也有跟ViewPage一样的控件，那就是PageView，PageView的用法也是相当的简单，代码如下：

```
Widget getPageView(index) {
    // 定义一个Controller，index为初始进去的Page的index
    PageController _transController = new PageController(initialPage: index);
    return PageView.builder(
        controller: _transController,
        itemCount: mImageList.length,// 可滑动Page的页数
        itemBuilder: (context, index) {
          return Image.file(File(mImageList[index]));//加载图片
        });
  }

```

## 4. 结语
通过这一个小小的Demo，可以看出，Flutter在UI方面的编写特别“节省代码”，通过短短的几行代码，就能实现很不错的效果。同样的，附上本文的Demo的Github地址：[Flutter_Image_Picker](https://github.com/chaojian/image_picker)


