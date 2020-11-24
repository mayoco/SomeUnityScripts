using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using UnityEngine.UI;

public class TcpClient : MonoBehaviour
{//连接到Tcp客户端并能够收发信息,断线重连,将客户端发送过来的信息显示在debugText中
    //手机开热点服务器ip 172.20.10.1 (不一定是这个,从网络设置中查看 ps.pc上cmd ipconfig显示所有)
    //usb网卡开热点服务器ip 192.168.137.243
    public Text debugText;
    public Socket m_socket;
    IPEndPoint m_endPoint;
    private SocketAsyncEventArgs m_connectSAEA;
    private SocketAsyncEventArgs m_sendSAEA;
    public string ip = "172.16.2.224";//服务器ip,这里编辑器中可以默认设为"0",通过ReadWriteFile读取文件上写的ip地址后进行指定
    public int port = 1910;
    private string preMsg = " ";
    bool needReconnect = false;

    private void Start()
    {
        //Client();
        Invoke("Client", 1f);
    }

    private void Update()
    {
        if (debugText && preMsg != " ") //接收消息
        {
            debugText.text = preMsg;//显示在Debug的UI上
            HandleMsg(preMsg);
            preMsg = " ";
        }
        if (needReconnect) //处理断线重连
        {
            Invoke("Client", 5f);
            needReconnect = false;
        }
    }

    public void Client()
    {
        m_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        IPAddress iPAddress = IPAddress.Parse(ip);
        m_endPoint = new IPEndPoint(iPAddress, port);
        m_connectSAEA = new SocketAsyncEventArgs { RemoteEndPoint = m_endPoint };
        m_connectSAEA.Completed += new EventHandler<SocketAsyncEventArgs>(OnConnectedCompleted);
        m_socket.ConnectAsync(m_connectSAEA);
    }

    private void OnConnectedCompleted(object sender, SocketAsyncEventArgs e)
    {
        if (e.SocketError != SocketError.Success) { needReconnect = true; return; }
        Socket socket = sender as Socket;
        string iPRemote = socket.RemoteEndPoint.ToString();

        Debug.Log("Client : 连接服务器" + iPRemote + "成功");

        SocketAsyncEventArgs receiveSAEA = new SocketAsyncEventArgs();
        byte[] receiveBuffer = new byte[1024 * 1024 * 16];
        receiveSAEA.SetBuffer(receiveBuffer, 0, receiveBuffer.Length);
        receiveSAEA.Completed += OnReceiveCompleted;
        receiveSAEA.RemoteEndPoint = m_endPoint;
        socket.ReceiveAsync(receiveSAEA);
    }

    private void OnReceiveCompleted(object sender, SocketAsyncEventArgs e)
    {

        if (e.SocketError == SocketError.OperationAborted) return;

        Socket socket = sender as Socket;

        Debug.Log("BytesTransferred " + e.BytesTransferred + " SocketError " + e.SocketError.ToString());

        if (e.SocketError == SocketError.Success && e.BytesTransferred > 0)
        {
            string ipAdress = socket.RemoteEndPoint.ToString();
            int lengthBuffer = e.BytesTransferred;
            byte[] receiveBuffer = e.Buffer;

            //读取指定位数的信息
            byte[] data = new byte[lengthBuffer];
            Array.Copy(receiveBuffer, 0, data, 0, lengthBuffer);
            string str = System.Text.Encoding.Default.GetString(data);

            string newstr = "R:" + str;

            Debug.Log(newstr);

            preMsg = str;//这里直接赋值给debugText.text无法更新,通过update中检测的方式更新信息

            //向服务器端发送消息
            Send("成功收到消息");

            socket.ReceiveAsync(e);
        }
        //else if (e.SocketError == SocketError.ConnectionReset && e.BytesTransferred == 0)
        //{
        //    Debug.Log("Client: 服务器断开连接 ");//服务器直接关闭时不会走到这一条
        //}
        else if (e.BytesTransferred == 0) //连接断开的处理
        {
            if (e.SocketError == SocketError.Success)
            {
                Debug.Log("主动断开连接 ");
                //DisConnect();
            }
            else
            {
                Debug.Log("被动断开连接 ");
            }
            needReconnect = true;//通过update中检测的方式更新信息
        }
        else
        {
            return;
        }
    }



    #region 发送
    void Send(string msg)
    {
        byte[] sendBuffer = Encoding.Default.GetBytes(msg);
        if (m_sendSAEA == null)
        {
            m_sendSAEA = new SocketAsyncEventArgs();
            m_sendSAEA.Completed += OnSendCompleted;
        }

        m_sendSAEA.SetBuffer(sendBuffer, 0, sendBuffer.Length);
        if (m_socket != null)
        {
            m_socket.SendAsync(m_sendSAEA);
        }
    }

    void OnSendCompleted(object sender1, SocketAsyncEventArgs e1)
    {
        if (e1.SocketError != SocketError.Success) return;
        Socket socket1 = sender1 as Socket;
        byte[] sendBuffer = e1.Buffer;

        string sendMsg = Encoding.Default.GetString(sendBuffer);

        Debug.Log("Client : Send message" + sendMsg + "to Serer" + socket1.RemoteEndPoint.ToString());
    }
    #endregion
    #region 断开连接
    void DisConnect()
    {
        Debug.Log("断开连接");
        if (m_socket != null)
        {
            try
            {
                m_socket.Shutdown(SocketShutdown.Both);
            }
            catch (SocketException excep)
            {
            }
            finally
            {
                m_socket.Close();
            }
        }
    }
    #endregion

    #region 处理接收到的信息
    void HandleMsg(string newMSg) 
    {
        switch (newMSg)
        {
            case "MainDisplay":
                SystemsManager.instance.StartSystemIndexBySystemChangeCheck(0);
                break;
            case "TenWangGe":
                SystemsManager.instance.StartSystemIndexBySystemChangeCheck(1);
                break;
            case "SmartMedical":
                SystemsManager.instance.StartSystemIndexBySystemChangeCheck(2);
                break;
            case "FireControl":
                SystemsManager.instance.StartSystemIndexBySystemChangeCheck(3);
                break;
            default:
                break;
        }
    }
    #endregion
}
