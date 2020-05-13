using System.Collections;
using System.Collections.Generic;
using System;
using System.Threading.Tasks;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;
using System.Linq;

public class DotweenTest : MonoBehaviour
{//常用方法详解 https://blog.csdn.net/zcaixzy5211314/article/details/84886663
 //https://blog.csdn.net/qq_34343249/article/details/105121484

    public Gradient gradient;
    public Camera testCamera;
    public Text text;
    public AnimationCurve curve;
    public Transform[] PointList;
    private Tween _tweener;

    // Start is called before the first frame update
    async void Start()
    {
        #region 常用组件拓展方法

        //Transform
        //position
        //transform.DOMove(Vector3.one, 1f);//移动到Vector3.one,运行时间1f
        //rotation
        //transform.DORotate(Vector3.zero, 1f);
        //transform.DOLookAt(Vector3.one, 1f);
        //scale
        //transform.DOScale(Vector3.zero, 1f);

        //Punch
        //第一个参数 punch：表示方向及强度
        //第二个参数 duration：表示动画持续时间
        //第三个参数 vibrato：震动次数
        //第四个参数 elascity: 这个值是0到1的
        //elascity为0时，物体就在起始点和目标点之间运动
        //elascity不为0时，会自动计算，产生一个反向点，数值越大方向点离的越远
        //transform.DOPunchPosition(Vector3.one, 4,10,0.5f);

        //Shake 参数：持续时间，力量，震动，随机性，淡出
        //力量：实际就是震动的幅度,可以理解成施加的力的大小 使用Vector3可以选择每个轴向不同的强度
        //震动：震动次数
        //随机性：改变震动方向的随机值（大小：0~180）
        //淡出：就是运动最后是否缓慢移动回到原本位置
        //transform.DOShakePosition(4, Vector3.one, 10);

        //Blend 混合动画 带Blend名称的方法，允许混合动画
        //原本同时执行两个Move方法，只会执行最新的一个动画命令
        //transform.DOBlendableMoveBy(Vector3.one, 1);//是增量动画，即移动到当前位置的+Vector3.one的位置
        //transform.DOBlendableMoveBy(-Vector3.one*2, 1);

        //回调
        //动画完成
        //transform.DOMove(Vector3.one, 2).OnComplete(() => { Debug.Log("DOMove Finished"); });

        //材质
        //ps.默认shader的Transparent选项并不能完全隐藏渲染 //默认材质的一些说明 https://gameinstitute.qq.com/community/detail/121052
        //-Transparent：透明物体，Albedo的A通道作为材质透明度，透明度下降时反射仍然保留。 
        //-Fade：类似Transparent，不过透明度下降时所有渲染效果都会淡出。
        //Material material = GetComponent<MeshRenderer>().material;
        //material.DOColor(Color.red, 10f);//颜色
        //material.DOColor(new Color(1,0,0,0),"_Color", 10f);
        //material.DOFade(0, 2);//修改透明度 隐藏
        //material.DOFade(0, "_Color", 2);
        //material.DOGradientColor(gradient, "_Color", 5);//gradient 渐变编辑器的设定 只对rgb有效, alpha值无效
        //material.DOOffset(new Vector2(1, 1), 2);//偏移
        //material.DOVector(new Vector4(1, 0, 0, 1), "_Color", 3);//改变提供的shader属性的名称对应的Vector4值
        //material.DOBlendableColor(new Color(1f, 0, 0, 1f),  3);//颜色混合
        //material.DOBlendableColor(new Color(0f, 0, 1f, 1f), 3);//混合效果感觉不太对？？？

        //相机
        //1）调整屏幕视角的宽高比 第一个参数是宽高的比值
        //testCamera.DOAspect(0.6f, 2);
        //2）改变相机background参数的颜色
        //testCamera.DOColor(Color.blue, 2);
        //3）改变相机近切面的值
        //testCamera.DONearClipPlane(200, 2);
        //4）改变相机远切面的值
        //testCamera.DOFarClipPlane(2000, 2);
        //5）改变相机FOV的值 Field of View
        //testCamera.DOFieldOfView(30, 5);
        //6）改变相机正交大小
        //testCamera.DOOrthoSize(10, 2);
        //7）按照屏幕像素计算的显示范围
        //testCamera.DOPixelRect(new Rect(0f, 0f, 600f, 500f), 2);
        //8）按照屏幕百分比计算的显示范围 可以配合做分屏效果
        //testCamera.DORect(new Rect(0.5f, 0.5f, 0.5f, 0.5f), 2);
        //9）相机震动
        //相机震动效果 参数：持续时间，力量，震动，随机性，淡出
        //力量：实际就是震动的幅度,可以理解成相机施加的力的大小 使用Vector3可以选择每个轴向不同的强度
        //震动：震动次数
        //随机性：改变震动方向的随机值（大小：0~180）
        //淡出：就是运动最后是否缓慢移动回到原本位置
        //testCamera.DOShakePosition(1, 1f, 10, 50, false);

        //Text
        //text.DOColor(Color.black, 2);
        //text.DOFade(0, 2);
        //text.DOBlendableColor(Color.black, 2);
        //把第一个参数传入的内容按照时间，一个字一个字的输入到文本框中 SetEase(Ease.Linear) 匀速
        //text.DOText("context", 2).SetEase(Ease.Linear);

        #endregion

        #region Dotween常用方法

        #region Sequence
        //两种使用方式
        //Sequence sequence = DOTween.Sequence();//先生成
        //DOTween.Sequence().Append(transform.DOMove(Vector3.one, 2));//或生成后直接使用
        //按顺序执行
        //sequence.Append(transform.DOMove(Vector3.one, 2));//1)添加动画到队列中 参数为Tween类型,为以上拓展方法的返回类型
        //sequence.AppendInterval(2);//2)添加时间间隔
        //sequence.Append(transform.DOMove(new Vector3(1, 0, 0), 2));
        //sequence.Append(transform.DOMove(new Vector3(1,0,0), 2).OnStart(() => Debug.Log("transformOnStart")).OnComplete(() => Debug.Log("transformComplete")));//测试运行顺序
        //3)按时间点插入动画
        //第一个参数为时间，此方法把动画插入到规定的时间点
        //以这句话为例，它把DORotate动画添加到此队列的0秒时执行，虽然它不是最先添加进队列的
        //sequence.Insert(0, transform.DORotate(new Vector3(0, 90, 0), 2));//Insert(6,xxx) 也可插入到其他动画不存在的时间点
        //sequence.Insert(1, transform.DORotate(new Vector3(0, 90, 0), 2).OnStart(() => Debug.Log("rotateOnStart")).OnComplete(() => Debug.Log("rotateComplete")));//测试运行顺序
        //4)加入当前动画
        //Join会加入和让动画与当前正在执行的动画一起执行->加入上一个Append方法
        //如下两行代码，DOMove会和DOScale一起执行
        //sequence.Append(transform.DOScale(new Vector3(2, 2, 2), 2));
        //sequence.Join(transform.DOMove(Vector3.one, 2));
        //5)预添加动画
        //预添加 会直接添加动画到Append的前面，也就是最开始的时候
        //sequence.Prepend(transform.DOScale(Vector3.one * 0.5f, 1));
        //这里需要特别说一下预添加的执行顺序问题
        //它这里也采取了队列的性质，不过，预添加与原本的的队列相比是一个反向队列 //即 Append是先进先出,Prepend是后进先出
        //例如：
        //Sequence sequence = DOTween.Sequence();
        //sequence.Append(transform.DOMove(Vector3.one, 2));
        //sequence.Prepend(transform.DOMove(-Vector3.one * 2, 2));
        //sequence.PrependInterval(1);
        //执行顺序是 PrependInterval----Prepend---- - Append
        //就是最后添加的会在队列的最顶端
        //6)预添加时间间隔
        //sequence.PrependInterval(1);

        //Sequence回调函数
        //1)预添加回调
        //sequence.PrependCallback(()=>Debug.Log("PreCallBack"));
        //2)在规定的时间点加入回调
        //sequence.InsertCallback(0, ()=>Debug.Log("InsertCallBack"));
        //3)添加回调
        //sequence.AppendCallback(()=>Debug.Log("AppendCallback"));
        #endregion

        #region Tweener设置 (链式编程,方法返回Tweener:DoTween动画的类型)
        //设置方式1.TweenParams
        //TweenParams para = new TweenParams();
        //Tweener move = transform.DOMove(Vector3.one, 1).SetAs(para);
        //设置方式2.直接设置
        //transform.DOMove(Vector3.one, 1f).SetLoops(-1,LoopType.Yoyo);//设置循环次数(-1 无限次)和循环类型
        //transform.DOMove(Vector3.one, 1f).SetAutoKill(true); //设置自动杀死动画 如果不kill,会运行完后会在缓存
        //transform.DOMove(Vector3.one, 1f).From(true);//补间 从目标点往起始点运动 参数 true，传入的就是偏移量 即当前坐标 + 传入值 = 目标值; falese，传入的就是目标值
        //transform.DOMove(Vector3.one, 2).SetDelay(1);//设置延迟
        //6）设置动画运动以速度为基准
        //transform.DOMove(Vector3.one, 1).SetSpeedBased();
        //使用SetSpeedBased时，移动方式就变成以速度为基准
        //原本表示持续时间的第二个参数，就变成表示速度的参数，每秒移动的单位数
        //7）设置动画ID
        //transform.DOMove(Vector3.one, 2).SetId("Id");//可以通过ID调用缓存动画  DOTween.Play("Id"); 但调用play方法，这个动画 不能是正在播放的，也不能是播放完成的
        //8）设置是否可回收
        //为true的话，动画播放完会被回收，缓存下来，不然播完就直接销毁
        //transform.DOMove(Vector3.one, 2).SetRecyclable(true);
        //9）设置动画为增量运动
        //transform.DOMove(Vector3.one, 2).SetRelative(true);
        //SetRelative参数 isRelative(相对的)：
        //为true，传入的就是偏移量，即当前坐标 + 传入值 = 目标值
        //为falese，传入的就是目标值，即传入值 = 目标值
        //10）设置动画的帧函数
        //transform.DOMove(Vector3.one, 2).SetUpdate(UpdateType.Normal, true);
        //第一个参数 UpdateType :选择使用的帧函数
        //UpdateType.Normal:更新每一帧中更新要求。 
        //UpdateType.Late:在LateUpdate调用期间更新每一帧。 
        //UpdateType.Fixed:使用FixedUpdate调用进行更新。 
        //UpdateType.Manual:通过手动DOTween.ManualUpdate调用进行更新。 需要另外设置 DOTween.ManualUpdate()
        //第二个参数：为TRUE，则补间将忽略Unity的Time.timeScale
        #endregion

        #region Ease运动曲线的设置
        //1）以Ease枚举作为参数 //对应效果网址 http://robertpenner.com/easing/easing_demo.html
        //例如：
        //transform.DOMove(Vector3.one, 2).SetEase(Ease.Flash, 3, 0f);
        //第二个参数 Amplitude(振幅)：实际就是移动次数，起始点移动到目标算移动一次，再移动回来移动两次
        //第三个参数 period 值的范围是 -1~1
        //值 > 0时，为活动范围的衰减值，活动范围会由大变小
        //值 = 0时，就是均匀的在起始坐标和目标坐标之间运动
        //值 < 0时，会施加一个向目标坐标的一个力，活动范围一点点增大，最后逼近目标点
        //这两个参数只对Flash, InFlash, OutFlash, InOutFlash这四种曲线有用，其他的曲线起作用的就只有Ease枚举参数
        //2）使用AnimationCurve当作参数
        //例如：
        //transform.DOMove(Vector3.one * 2, 1).SetEase(curve);
        //AnimationCurve 横轴是时间, 不过不是具体的时间，而是时间比例
        //AnimationCurve 纵轴是倍数
        //假设纵轴的值为v，传入DOMove的第一个参数endValue是e，起始点坐标是s
        //此物体最后动画结束时的实际坐标即为 v * （e - s）+s
        //3）以回调函数为参数
        //例如：
        //transform.DOMove(Vector3.one * 2, 1).SetEase(MyEaseFun);//参数需要是EaseFunction,
        //即public float EaseFunction(float time, float duration, float overshootOrAmplitude, float period)这个形式的
        ////返回值是运动距离的百分比 值应为0~1之间，最后的值需为1,不然停留的位置不会是目标位置 time：当前时间 
        //private float MyEaseFun(float time, float duration, float overshootOrAmplitude, float period)
        //{
        //return time / duration;
        //}
        #endregion

        #region 回调函数
        //1）动画完成回调
        //transform.DOMove(Vector3.one, 2).OnComplete(() => { });
        //2）动画被杀死时回调
        //transform.DOMove(Vector3.one, 2).OnKill(() => { });
        //3）动画播放时回调,暂停后重新播放也会调用
        //transform.DOMove(Vector3.one, 3).OnPlay(() => { });
        //4）动画暂停时回调
        //transform.DOMove(Vector3.one, 2).OnPause(() => { });
        //5）动画回退时回调
        //以下情况会被调用
        //使用DORestart重新播放时
        //使用Rewind倒播动画完成时
        //使用DOFlip翻转动画完成时
        //使用DOPlayBackwards反向播放动画完成时
        //transform.DOMove(Vector3.one, 2).OnRewind(() => { });
        //6）只在第一次播放动画时调用，在play之前调用
        //transform.DOMove(Vector3.one, 2).OnStart(() => { });
        //7）完成单个循环周期时触发 比如动画循环三次，会调用三次
        //transform.DOMove(Vector3.one, 2).OnStepComplete(() => { });
        //transform.DOMove(Vector3.one, 2).SetLoops(-1, LoopType.Yoyo).OnStepComplete(() => { Debug.Log("OnStepComplete"); });
        //8）帧回调
        //transform.DOMove(Vector3.one, 2).OnUpdate(() => { });
        //9）在路径动画时，改变目标点时的回调，参数为当前目标点的下标
        //transform.DOMove(Vector3.one, 2).OnWaypointChange((value) => { });
        #endregion

        #region 动画控制方法
        //1)播放
        //transform.DOPlay();
        //2)暂停
        //transform.DOPause();
        //3)重播
        //transform.DORestart();
        //4)倒播，此方法会直接退回起始点
        //transform.DORewind();
        //5)平滑倒播，此方法会按照之前的运动方式从当前位置退回起始点
        //transform.DOSmoothRewind();
        //eg:
        //transform.DOMove(Vector3.one, 2);
        //await Task.Delay(TimeSpan.FromSeconds(1));//.net 4.6 以上版本支持 Start需要标记async, 引用命名空间 System, System.Threading.Tasks
        //transform.DOSmoothRewind();
        //6)杀死动画
        //transform.DOKill();
        //7)翻转补间的方向
        //transform.DOFlip();//把目标点和起始点翻转过来
        //8)跳转时间点
        // 第一个参数跳转的时间点，第二个参数是跳转后是否播放动画
        //transform.DOGoto(1.5f, true);
        //9）反向播放动画
        // 反向播放动画，在动画播放到一半时执行，会退回起始点，在一开始执行看不到效果是因为，物体本身就在起始点
        //transform.DOPlayBackwards();
        //10）正向播放动画
        //transform.DOPlayForward();
        //11）TogglePause
        //  当暂停时，执行就继续播放，播放时，执行就暂停
        //transform.DOTogglePause();
        #endregion

        #region 获取数据的方法
        //一、类方法
        //1）返回所有暂停的动画，没有则返回null
        //DOTween.PausedTweens();
        //2）返回所有真正播放的动画，没有则返回null
        //DOTween.PlayingTweens();
        //3）获取给定ID的数组
        //    例如：
        //DOTween.TweensById("id", true);
        //返回满足条件的动画数组
        //第一个参数是动画的ID
        //第二个参数是是否只收集正在播放的动画
        //4）返回给定对象的数组
        //例如：
        //DOTween.TweensByTarget(transform, true);
        //返回满足条件的动画数组
        //第一个参数是播放动画的对象
        //    例如：transform.DOMove(Vector3.one, 2); 第一个参数就传入transform
        //        material.DOColor(Color.White, 2); 第一个参数就传入材质对象material
        //    第二个参数是是否只收集正在播放的动画
        //5）收集传入的对象是否有动画在活动
        //例如：
        //DOTween.IsTweening(transform);
        //第一个参数为检测的对象
        //第二个参数为是否检测动画在播放状态
        //    为true时，给定对象在播放状态时 返回true
        //    为false时，只检测给定对象是否有动画（在pause状态时也算）有则返回true
        //6）正在播放的动画的总数，目前处于延迟播放状态的动画也算
        //DOTween.TotalPlayingTweens();

        //二、实例方法
        //Tweener _tweener = transform.DOMove(Vector3.one, 2);
        //1）fullPosition 表示动画执行时间的属性，可读可写
        //await Task.Delay(TimeSpan.FromSeconds(1f));
        //_tweener.fullPosition = 0f;
        //2）表示动画执行完的次数
        //_tweener.CompletedLoops()
        //await Task.Delay(TimeSpan.FromSeconds(1.1f));
        //Debug.Log(_tweener.CompletedLoops());//1.1s ->1
        //await Task.Delay(TimeSpan.FromSeconds(1.1f));
        //Debug.Log(_tweener.CompletedLoops());//2.2s ->2
        //await Task.Delay(TimeSpan.FromSeconds(1.1f));
        //Debug.Log(_tweener.CompletedLoops());//3.3s ->0 This Tween has been killed and is now invalid
        //3）获取动画的延迟时间
        //_tweener.Delay();
        //4）获取动画的持续时间
        //    参数为true 表示计算循环的时间，无限循环为Infinity
        //_tweener.Duration(false)
        //5）动画已播放的时间
        //参数为true 表示计算循环的时间
        //_tweener.Elapsed()
        //6）返回动画进度的百分比
        //起始点为0 目标点为1 当yoyo循环模式下，值会从0变到1再从1变到0
        //_tweener.ElapsedDirectionalPercentage()
        //7）返回动画区间已用的百分比
        //单次循环的数值为0到1
        //参数为 是否包含循环 为true时 返回值是循环总区间的已用百分比 若为无限循环 返回值为0
        //_tweener.ElapsedPercentage(true)
        //8）动画是否在活动
        //_tweener.IsActive();
        //9）是否是反向动画
        //_tweener.IsBackwards();
        //10）动画是否完成
        //_tweener.IsComplete();
        //11）是否已初始化
        //_tweener.IsInitialized();
        //12）是否正在播放
        //_tweener.IsPlaying();
        //13）返回循环次数，  无限循环为Infinity
        //_tweener.Loops();

        #endregion

        #region 携程
        StartCoroutine(Wait());
        #endregion

        #endregion

        #region Dotween路径动画
        //路径动画使用方法详解 https://blog.csdn.net/zcaixzy5211314/article/details/84988535
        //var positions = PointList.Select(u => u.position).ToArray();//Linq转换成Transform[]
        //transform.DOPath(positions, 5, PathType.CatmullRom, PathMode.Full3D, 10, Color.blue) //waypoints duration pathType pathModel resolution gizmoColor
        //    .SetOptions(true, AxisConstraint.None,AxisConstraint.Z)//closePath lockPosition lockRotation
        //    .SetLookAt(0);//lookAhead 参数的意思就是 看前看的偏移量 假设整个路径normalize. 即开始点为0,结束点为1. 走到路程的一半即为0.5.
        //                  //所以如果lookAhead = 0.5 时, 假设当前Transform行走进程到 0.1的位置,则会 LookAt 行走进程 0.6的位置.
        #endregion
    }

    // Update is called once per frame
    void Update()
    {
        //动画控制方法 ...
        //if (Input.GetKeyDown(KeyCode.T)) 
        //{
        //    testCamera.DOPause();
        //}
        //if (Input.GetKeyDown(KeyCode.G))
        //{
        //    testCamera.DOPlay();
        //}

    }

    //自定义函数设置运动曲线
    private float MyEaseFun(float time, float duration, float overshootOrAmplitude, float period)
    {
        return time / duration;
    }

    //携程方法  (DoTween回调函数的替代解决方案)
    private IEnumerator Wait()
    {
        _tweener = transform.DOMove(Vector3.one, 2);

        //1)等待动画执行完
        //yield return _tweener.WaitForCompletion();

        //2）等待指定的循环次数
        //  参数为执行次数，等待传入的循环次数后，继续执行
        //  若是传入的次数大于动画的循环次数 则在动画结束时继续执行
        //  yield return _tweener.WaitForElapsedLoops(2);

        //3）等待动画被杀死
        //  yield return _tweener.WaitForKill();

        //4）等待动画执行指定时间
        //  参数为时间，动画执行传入的时间之后或动画执行完毕，继续执行
        //  yield return _tweener.WaitForPosition(0.5f);

        //5）等待动画回退
        //  以下情况会继续执行函数
        //使用DORestart重新播放时
        //使用Rewind倒播动画完成时
        //使用DOFlip翻转动画完成时
        //使用DOPlayBackwards反向播放动画完成时
        //yield return _tweener.WaitForRewind();

        //6）等待Start执行后继续执行
          yield return _tweener.WaitForStart();
    }

}
