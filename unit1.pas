unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  ExtCtrls, RTTICtrls, Spin, IniFiles, LCLProc, Process, LCLIntf, ComCtrls;

type

  // 定义一个记录来存储字体信息
  TFontInfo = record
    DisplayName: string;
    Path: string;
  end;
  TFontInfoArray = array of TFontInfo;

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox10: TComboBox; // 新增：触屏切换
    ComboBox11: TComboBox; // 新增：菜单风格
    ComboBox12: TComboBox; // 新增：菜单模式
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    ComboBox9: TComboBox;
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit2: TEdit;
    Edit5: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SpinEdit9: TSpinEdit;
    StaticText1: TStaticText;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    SpinEdit10: TSpinEdit;
    TrackBar8: TTrackBar;
    procedure ComboBox2Change(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseEnter(Sender: TObject);
    procedure Image2MouseLeave(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image3MouseEnter(Sender: TObject);
    procedure Image3MouseLeave(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure StaticText1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure SpinEditChange(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
  private
    FIniFile: TMemIniFile; // 仍然保留用于读取
    FFonts: TFontInfoArray;
    FIniPath: string;
    // *** 新增：用于防止事件递归触发 ***
    FUpdating: Boolean;

    procedure UpdatePlayerNumValue;
    procedure UpdatePlayerWFValue;
    // *** 新增：智能写入方法 ***
    procedure SmartWriteValue(const ASection, AKey, AValue: string);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  LResources; // 将 LResources 单元移动到 implementation 部分

const
  RT_RCDATA = PChar(10);  // 定义 RT_RCDATA 以修复编译错误

// 辅助过程：向字体数组中添加新字体
procedure AddFont(var FontArray: TFontInfoArray; const DisplayName, Path: string);
var
  i: Integer;
begin
  i := Length(FontArray);
  SetLength(FontArray, i + 1);
  FontArray[i].DisplayName := DisplayName;
  FontArray[i].Path := Path;
end;

// 辅助函数：根据路径查找字体在数组中的索引
function FindFontByPath(const FontArray: TFontInfoArray; const Path: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(FontArray) do
    if SameText(FontArray[i].Path, Path) then
    begin
      Result := i;
      Exit;
    end;
end;

// *** 新增的智能写入实现 ***
procedure TForm1.SmartWriteValue(const ASection, AKey, AValue: string);
var
  Lines: TStringList;
  i: Integer;
  InSection: Boolean;
  SectionLine: Integer;
  KeyPos: Integer;
  TrimmedLine, CurrentKey: string;
begin
  if not FileExists(FIniPath) then Exit; // 安全检查

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FIniPath, TEncoding.UTF8);

    InSection := False;
    SectionLine := -1;

    // 遍历所有行，尝试寻找并更新已存在的键
    for i := 0 to Lines.Count - 1 do
    begin
      TrimmedLine := Trim(Lines[i]);
      if (Length(TrimmedLine) > 2) and (TrimmedLine[1] = '[') and (TrimmedLine[Length(TrimmedLine)] = ']') then
      begin
        // 检查是否进入了正确的段
        if SameText(Copy(TrimmedLine, 2, Length(TrimmedLine) - 2), ASection) then
        begin
          InSection := True;
          SectionLine := i;
        end
        else
        begin
          InSection := False;
        end;
      end
      else if InSection then
      begin
        // 如果在正确的段内，检查键是否匹配
        KeyPos := Pos('=', TrimmedLine);
        if KeyPos > 0 then
        begin
          CurrentKey := Trim(Copy(TrimmedLine, 1, KeyPos - 1));
          if SameText(CurrentKey, AKey) then
          begin
            // 找到了！更新这一行并保存，然后退出
            Lines[i] := AKey + '=' + AValue;
            Lines.SaveToFile(FIniPath, TEncoding.UTF8);
            Exit;
          end;
        end;
      end;
    end;

    // 如果代码执行到这里，说明文件中不存在这个键，需要新增
    if SectionLine <> -1 then
    begin
      // 段存在，就在段的标题下一行插入新的键值对
      Lines.Insert(SectionLine + 1, AKey + '=' + AValue);
    end
    else
    begin
      // 如果连段都找不到，就在文件末尾添加段和键值对
      if (Lines.Count > 0) and (Trim(Lines[Lines.Count - 1]) <> '') then
        Lines.Add(''); // 添加一个空行，格式更好看
      Lines.Add('[' + ASection + ']');
      Lines.Add(AKey + '=' + AValue);
    end;

    // 保存新增键值对后的文件
    Lines.SaveToFile(FIniPath, TEncoding.UTF8);

  finally
    Lines.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  FontSearchPath: string;
  i: Integer;
  SelectedFontPath: string;
begin
  // *** 新增：初始化 FUpdating 标志，防止在加载时触发循环事件 ***
  FUpdating := True;
  try
    // *** 将路径保存到成员变量 FIniPath ***
    FIniPath := ExtractFilePath(ParamStr(0)) + 'Dream.ini';
    {$ifdef DARWIN}    // mac的app包内路径，需向上返回三层目录
    FIniPath := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExtractFileDir(ParamStr(0))))) + PathDelim + 'Dream.ini';
    {$else} //与二进制文件在相同目录
    FIniPath := ExtractFilePath(ParamStr(0)) + 'Dream.ini';
    {$endif}

    if not FileExists(FIniPath) then
    begin
      ShowMessage('配置文件 "Dream.ini" 未找到。' + #13#10 + '请确保该文件与应用程序在同一目录下。');
      Application.Terminate;
      Exit;
    end;

    FIniFile := TMemIniFile.Create(FIniPath, TEncoding.UTF8);

    // 初始化字体数组
    SetLength(FFonts, 0);

    // 为每个 CheckBox 绑定 OnClick 事件
    CheckBox1.OnClick := @CheckBoxClick;
    CheckBox2.OnClick := @CheckBoxClick;
    CheckBox3.OnClick := @CheckBoxClick;
    CheckBox4.OnClick := @CheckBoxClick;
    CheckBox5.OnClick := @CheckBoxClick;
    CheckBox6.OnClick := @CheckBoxClick;
    CheckBox7.OnClick := @CheckBoxClick;
    CheckBox8.OnClick := @CheckBoxClick;

    // 读取 INI 文件并设置 CheckBox 状态
    CheckBox1.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.FullScreen', 0) = 1;
    CheckBox2.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.ScreenZoomMode', 0) = 1;
    CheckBox3.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.OSCharSet', 0) = 1;
    CheckBox4.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.DrawMini', 0) = 1;

    case FIniFile.ReadInteger('CONFIG', 'Sys.Replay', 0) of
      0: CheckBox5.Checked := False;
      1: CheckBox5.Checked := True;
      2: CheckBox5.State := cbGrayed;
    end;

    CheckBox6.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.AutoConfirm', 0) = 1;
    CheckBox7.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.HPDisplay', 0) = 1;
    CheckBox8.Checked := FIniFile.ReadInteger('CONFIG', 'Sys.ShowBust', 0) = 1;

    // --- TTrackBar & TSpinEdit 初始化和事件绑定 ---
    TrackBar1.OnChange := @TrackBarChange;
    TrackBar2.OnChange := @TrackBarChange;
    TrackBar3.OnChange := @TrackBarChange;
    TrackBar4.OnChange := @TrackBarChange;
    TrackBar5.OnChange := @TrackBarChange;
    TrackBar6.OnChange := @TrackBarChange;
    TrackBar7.OnChange := @TrackBarChange;
    TrackBar8.OnChange := @TrackBarChange;

    SpinEdit1.OnChange := @SpinEditChange;
    SpinEdit2.OnChange := @SpinEditChange;
    SpinEdit3.OnChange := @SpinEditChange;
    SpinEdit4.OnChange := @SpinEditChange;
    SpinEdit5.OnChange := @SpinEditChange;
    SpinEdit6.OnChange := @SpinEditChange;
    SpinEdit7.OnChange := @SpinEditChange;
    SpinEdit8.OnChange := @SpinEditChange;
    SpinEdit9.OnChange := @SpinEditChange;
    SpinEdit10.OnChange := @SpinEditChange;

    // 设置TTrackBar和TSpinEdit1-6的范围和初始值
    TrackBar1.Min := 0; TrackBar1.Max := 128;
    SpinEdit1.MinValue := 0; SpinEdit1.MaxValue := 128;
    TrackBar1.Position := FIniFile.ReadInteger('CONFIG', 'Sys.MusicVolume', 128);
    SpinEdit1.Value := TrackBar1.Position;

    TrackBar2.Min := 0; TrackBar2.Max := 128;
    SpinEdit2.MinValue := 0; SpinEdit2.MaxValue := 128;
    TrackBar2.Position := FIniFile.ReadInteger('CONFIG', 'Sys.SoundVolume', 128);
    SpinEdit2.Value := TrackBar2.Position;

    TrackBar3.Min := 0; TrackBar3.Max := 60;
    SpinEdit3.MinValue := 0; SpinEdit3.MaxValue := 60;
    TrackBar3.Position := FIniFile.ReadInteger('CONFIG', 'Sys.FrameRate', 0);
    SpinEdit3.Value := TrackBar3.Position;

    TrackBar4.Min := 0; TrackBar4.Max := 60;
    SpinEdit4.MinValue := 0; SpinEdit4.MaxValue := 60;
    TrackBar4.Position := FIniFile.ReadInteger('CONFIG', 'Sys.BattleDelay', 30);
    SpinEdit4.Value := TrackBar4.Position;

    TrackBar5.Min := 2; TrackBar5.Max := 12;
    SpinEdit5.MinValue := 2; SpinEdit5.MaxValue := 12;
    TrackBar5.Position := FIniFile.ReadInteger('CONFIG', 'Net.PlayerNum', 2);
    SpinEdit5.Value := TrackBar5.Position;

    TrackBar6.Min := 1; TrackBar6.Max := 11;
    SpinEdit6.MinValue := 1; SpinEdit6.MaxValue := 11;
    TrackBar6.Position := FIniFile.ReadInteger('CONFIG', 'Net.PlayerWF', 1);
    SpinEdit6.Value := TrackBar6.Position;

    TrackBar7.Min := 40; TrackBar7.Max := 150;
    SpinEdit7.MinValue := 40; SpinEdit7.MaxValue := 150;
    TrackBar7.Position := FIniFile.ReadInteger('CONFIG', 'Sys.ScreenZoom', 100);
    SpinEdit7.Value := TrackBar7.Position;

    TrackBar8.Min := 100; TrackBar8.Max := 200;
    SpinEdit8.MinValue := 100; SpinEdit8.MaxValue := 200;
    TrackBar8.Position := FIniFile.ReadInteger('CONFIG', 'Sys.Zoom', 100);
    SpinEdit8.Value := TrackBar8.Position;

    SpinEdit9.MinValue := 1;
    SpinEdit9.MaxValue := 131;
    SpinEdit9.Value := FIniFile.ReadInteger('CONFIG', 'Net.BattleField', 1);

    SpinEdit10.MinValue := 0;
    SpinEdit10.MaxValue := 65535;
    SpinEdit10.Value := FIniFile.ReadInteger('CONFIG', 'Net.HostPort', 35415);

    // 检查并确保 Net.PlayerWF <= Net.PlayerNum - 1
    UpdatePlayerWFValue;

    // --- TEdit 初始化和事件绑定 ---
    Edit1.OnChange := @EditChange;
    Edit2.OnChange := @EditChange;
    Edit3.OnChange := @EditChange;

    Edit1.Text := FIniFile.ReadString('CONFIG', 'Sys.PlayName', '天下无双');
    Edit2.Text := FIniFile.ReadString('CONFIG', 'Net.HostAddress', '127.0.0.1');
    Edit3.Text := FIniFile.ReadString('CONFIG', 'Net.PlayerName', '大梦倚天');

    // --- TComboBox 初始化和事件绑定 ---
    ComboBox1.OnChange := @ComboBoxChange;
    ComboBox2.OnChange := @ComboBoxChange;
    ComboBox3.OnChange := @ComboBoxChange;
    ComboBox4.OnChange := @ComboBoxChange;
    ComboBox5.OnChange := @ComboBoxChange;
    ComboBox6.OnChange := @ComboBoxChange;
    ComboBox7.OnChange := @ComboBoxChange;
    ComboBox8.OnChange := @ComboBoxChange;
    ComboBox9.OnChange := @ComboBoxChange;
    ComboBox10.OnChange := @ComboBoxChange;
    ComboBox11.OnChange := @ComboBoxChange;
    ComboBox12.OnChange := @ComboBoxChange;

    // ComboBox1: Sys.RenderMode (1-5, 0)
    ComboBox1.Clear;
    {$ifdef WINDOWS}
    ComboBox1.Items.Add('软件渲染');
    ComboBox1.Items.Add('Direct3D9');
    ComboBox1.Items.Add('Direct3D11');
    ComboBox1.Items.Add('Direct3D12');
    ComboBox1.Items.Add('OpenGL');
    ComboBox1.Items.Add('Vulkan');
    {$endif}
    {$ifdef DARWIN}
    ComboBox1.Items.Add('软件渲染');
    ComboBox1.Items.Add('Metal');
    {$endif}
    {$ifdef LINUX}
    ComboBox1.Items.Add('软件渲染');
    ComboBox1.Items.Add('OpenGL');
    {$endif}
    ComboBox1.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.RenderMode', 0);

    // ComboBox2: Sys.FontName
    ComboBox2.Clear;

    // 填充字体数组和 ComboBox
    AddFont(FFonts, '默认字体', 'data/font.ttf');
    {$ifdef WINDOWS}
    FontSearchPath := GetEnvironmentVariable('windir') + '\Fonts\';
    if FileExists(FontSearchPath + 'simsun.ttc') then AddFont(FFonts, '宋体', FontSearchPath + 'simsun.ttc');
    if FileExists(FontSearchPath + 'simfang.ttf') then AddFont(FFonts, '仿宋', FontSearchPath + 'simfang.ttf');
    if FileExists(FontSearchPath + 'FZSTK.ttf') then AddFont(FFonts, '方正舒体', FontSearchPath + 'FZSTK.ttf');
    if FileExists(FontSearchPath + 'STCAIYUN.ttf') then AddFont(FFonts, '华文行彩', FontSearchPath + 'STCAIYUN.ttf');
    if FileExists(FontSearchPath + 'simkai.ttf') then AddFont(FFonts, '楷书', FontSearchPath + 'simkai.ttf');
    if FileExists(FontSearchPath + 'STLITI.ttf') then AddFont(FFonts, '华文隶书', FontSearchPath + 'STLITI.ttf');
    if FileExists(FontSearchPath + 'STKAITI.ttf') then AddFont(FFonts, '华文行楷', FontSearchPath + 'STKAITI.ttf');
    {$endif}
    {$ifdef DARWIN}
    FontSearchPath := '/System/Library/Fonts/';
    if FileExists(FontSearchPath + 'STHeiti Light.ttc') then AddFont(FFonts, '华文细黑', FontSearchPath + 'STHeiti Light.ttc');
    if FileExists(FontSearchPath + 'Hiragino Sans GB.ttc') then AddFont(FFonts, '冬青黑体简体', FontSearchPath + 'Hiragino Sans GB.ttc');
    if FileExists(FontSearchPath + 'STHeiti Medium.ttc') then AddFont(FFonts, '华文黑体', FontSearchPath + 'STHeiti Medium.ttc');
    {$endif}
    {$ifdef LINUX}

    {$endif}

    // 遍历字体数组，填充 ComboBox 的 Items
    for i := 0 to High(FFonts) do
      ComboBox2.Items.Add(FFonts[i].DisplayName);

    // 根据INI文件中的路径找到对应的显示名称并设置 ComboBox 的值
    SelectedFontPath := FIniFile.ReadString('CONFIG', 'Sys.FontName', 'data/font.ttf');
    // *** 读取时去除双引号 ***
    if (Length(SelectedFontPath) > 2) and (SelectedFontPath[1] = '"') and (SelectedFontPath[Length(SelectedFontPath)] = '"') then
      SelectedFontPath := Copy(SelectedFontPath, 2, Length(SelectedFontPath) - 2);

    i := FindFontByPath(FFonts, SelectedFontPath);
    if i <> -1 then
      ComboBox2.ItemIndex := i
    else
      ComboBox2.ItemIndex := 0; // 如果INI中的路径不在列表中，则设为默认

    // ComboBox3: Sys.Shouting (0-3)
    ComboBox3.Clear;
    ComboBox3.Items.Add('禁用');
    ComboBox3.Items.Add('全武功');
    ComboBox3.Items.Add('威力天外');
    ComboBox3.Items.Add('天赋外功');
    ComboBox3.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.Shouting', 0);

    // ComboBox4: Sys.Shoutlang (1-5)
    ComboBox4.Clear;
    ComboBox4.Items.Add('国语');
    ComboBox4.Items.Add('粤语');
    ComboBox4.Items.Add('台语');
    ComboBox4.Items.Add('四川话');
    ComboBox4.Items.Add('东北话');
    ComboBox4.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.Shoutlang', 1) - 1;

    // ComboBox5: Sys.EnableJoyStick (0, 2)
    ComboBox5.Clear;
    ComboBox5.Items.Add('禁用');
    ComboBox5.Items.Add('自适应');
    i := FIniFile.ReadInteger('CONFIG', 'Sys.EnableJoyStick', 0);
    if i = 2 then
      ComboBox5.ItemIndex := 1
    else
      ComboBox5.ItemIndex := 0;

    // ComboBox6: Sys.FallowNum (1-6)
    ComboBox6.Clear;
    ComboBox6.Items.Add('禁用');
    ComboBox6.Items.Add('2人');
    ComboBox6.Items.Add('3人');
    ComboBox6.Items.Add('4人');
    ComboBox6.Items.Add('5人');
    ComboBox6.Items.Add('6人');
    i := FIniFile.ReadInteger('CONFIG', 'Sys.FallowNum', 1);
    if i = 0 then
      ComboBox6.ItemIndex := 0
    else
      ComboBox6.ItemIndex := i - 1;

    // ComboBox7: Sys.AutoUpgrade (0-5)
    ComboBox7.Clear;
    ComboBox7.Items.Add('随机加点');
    ComboBox7.Items.Add('提示加点');
    ComboBox7.Items.Add('手动加点');
    ComboBox7.Items.Add('自动加攻');
    ComboBox7.Items.Add('自动加防');
    ComboBox7.Items.Add('自动加轻');
    ComboBox7.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.AutoUpgrade', 0);

    // ComboBox8: Net.BattleStand (0-2)
    ComboBox8.Clear;
    ComboBox8.Items.Add('默认站位');
    ComboBox8.Items.Add('随机站位');
    ComboBox8.Items.Add('自定义站位');
    ComboBox8.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Net.BattleStand', 0);

    // ComboBox9: Net.BattleSelect (1-16)
    ComboBox9.Clear;
    ComboBox9.Items.Add('华山后山');
    ComboBox9.Items.Add('华山绝顶');
    ComboBox9.Items.Add('武林大会');
    ComboBox9.Items.Add('仙灵岛');
    ComboBox9.Items.Add('皇宫');
    ComboBox9.Items.Add('北京城');
    ComboBox9.Items.Add('少林寺');
    ComboBox9.Items.Add('武当山');
    ComboBox9.Items.Add('重阳宫');
    ComboBox9.Items.Add('百花谷');
    ComboBox9.Items.Add('光明顶');
    ComboBox9.Items.Add('襄阳城');
    ComboBox9.Items.Add('黑木崖');
    ComboBox9.Items.Add('侠客岛');
    ComboBox9.Items.Add('随机战场');
    ComboBox9.Items.Add('自定义');
    ComboBox9.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Net.BattleSelect', 1) - 1;

    // --- 新增代码：根据 ComboBox9 的初始值设置 SpinEdit9 的状态 ---
    SpinEdit9.Enabled := (ComboBox9.ItemIndex = 15);

    // ComboBox10: Sys.TouchSwitch (0-2) - 新增
    ComboBox10.Clear;
    ComboBox10.Items.Add('禁用');
    ComboBox10.Items.Add('中上切换');
    ComboBox10.Items.Add('左上切换');
    ComboBox10.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.TouchSwitch', 1);

    // ComboBox11: Sys.MenuStyle (0-10) - 新增
    ComboBox11.Clear;
    ComboBox11.Items.Add('默认风格');       // 0
    ComboBox11.Items.Add('经典黑白');       // 1
    ComboBox11.Items.Add('羊皮古卷');       // 2
    ComboBox11.Items.Add('青竹丹青');       // 3
    ComboBox11.Items.Add('赤壁战帖');       // 4
    ComboBox11.Items.Add('紫禁之巅');       // 5
    ComboBox11.Items.Add('水墨丹青');       // 6
    ComboBox11.Items.Add('桃花岛');         // 7
    ComboBox11.Items.Add('古墓寒玉');       // 8
    ComboBox11.Items.Add('青铜铭文');       // 9
    ComboBox11.Items.Add('寒冰玄铁');       // 10
    ComboBox11.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.MenuStyle', 0);

    // ComboBox12: Sys.MenuSelectBox (0-1) - 新增
    ComboBox12.Clear;
    ComboBox12.Items.Add('面板模式');
    ComboBox12.Items.Add('按钮模式');
    ComboBox12.ItemIndex := FIniFile.ReadInteger('CONFIG', 'Sys.MenuSelectBox', 0);

  finally
    // *** 确保在所有初始化完成后，将 FUpdating 设置为 False ***
    FUpdating := False;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // FIniFile 只用于读取，写入由 SmartWriteValue 实时完成，
  // 所以这里只需释放对象即可。
  if Assigned(FIniFile) then
    FIniFile.Free;
end;

procedure TForm1.CheckBoxClick(Sender: TObject);
var
  CheckBox: TCheckBox;
  IniKey: string;
  Val: Integer;
begin
  if not (Sender is TCheckBox) then Exit;

  IniKey := '';
  Val := 0;

  CheckBox := Sender as TCheckBox;
  if CheckBox = CheckBox1 then IniKey := 'Sys.FullScreen'
  else if CheckBox = CheckBox2 then IniKey := 'Sys.ScreenZoomMode'
  else if CheckBox = CheckBox3 then IniKey := 'Sys.OSCharSet'
  else if CheckBox = CheckBox4 then IniKey := 'Sys.DrawMini'
  else if CheckBox = CheckBox5 then IniKey := 'Sys.Replay'
  else if CheckBox = CheckBox6 then IniKey := 'Sys.AutoConfirm'
  else if CheckBox = CheckBox7 then IniKey := 'Sys.HPDisplay'
  else if CheckBox = CheckBox8 then IniKey := 'Sys.ShowBust';

  if IniKey <> '' then
  begin
    if CheckBox = CheckBox5 then
      case CheckBox.State of
        cbChecked: Val := 1;
        cbUnchecked: Val := 0;
        cbGrayed: Val := 2;
      end
    else
    begin
      if CheckBox.Checked then Val := 1 else Val := 0;
    end;

    // *** 使用智能写入方法 ***
    SmartWriteValue('CONFIG', IniKey, IntToStr(Val));
  end;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin

end;

procedure TForm1.TrackBarChange(Sender: TObject);
var
  TrackBar: TTrackBar;
  IniSection, IniKey: string;
  Val: Integer;
begin
  // *** 新增：如果正在更新，则退出以防止循环 ***
  if FUpdating then Exit;

  if not (Sender is TTrackBar) then Exit;

  IniSection := '';
  IniKey := '';

  TrackBar := Sender as TTrackBar;

  // *** 在改变其他组件的值之前，先设置 FUpdating 为 True ***
  FUpdating := True;
  try
    if TrackBar = TrackBar1 then begin IniSection := 'CONFIG'; IniKey := 'Sys.MusicVolume'; SpinEdit1.Value := TrackBar.Position; end
    else if TrackBar = TrackBar2 then begin IniSection := 'CONFIG'; IniKey := 'Sys.SoundVolume'; SpinEdit2.Value := TrackBar.Position; end
    else if TrackBar = TrackBar3 then begin IniSection := 'CONFIG'; IniKey := 'Sys.FrameRate'; SpinEdit3.Value := TrackBar.Position; end
    else if TrackBar = TrackBar4 then begin IniSection := 'CONFIG'; IniKey := 'Sys.BattleDelay'; SpinEdit4.Value := TrackBar.Position; end
    else if TrackBar = TrackBar5 then begin IniSection := 'CONFIG'; IniKey := 'Net.PlayerNum'; SpinEdit5.Value := TrackBar.Position; UpdatePlayerWFValue; end
    else if TrackBar = TrackBar6 then begin IniSection := 'CONFIG'; IniKey := 'Net.PlayerWF'; SpinEdit6.Value := TrackBar.Position; UpdatePlayerNumValue; end
    else if TrackBar = TrackBar7 then begin IniSection := 'CONFIG'; IniKey := 'Sys.ScreenZoom'; SpinEdit7.Value := TrackBar.Position; end
    else if TrackBar = TrackBar8 then begin IniSection := 'CONFIG'; IniKey := 'Sys.Zoom'; SpinEdit8.Value := TrackBar.Position; end;
  finally
    // *** 确保在所有操作完成后，将 FUpdating 设置回 False ***
    FUpdating := False;
  end;

  if IniKey <> '' then
  begin
    // 直接写入 TrackBar 的位置，不再需要偏移
    Val := TrackBar.Position;
    // *** 使用智能写入方法 ***
    SmartWriteValue(IniSection, IniKey, IntToStr(Val));
  end;
end;

procedure TForm1.SpinEditChange(Sender: TObject);
var
  SpinEdit: TSpinEdit;
  IniSection, IniKey: string;
  Val: Integer;
begin
  // *** 新增：如果正在更新，则退出以防止循环 ***
  if FUpdating then Exit;

  if not (Sender is TSpinEdit) then Exit;

  IniSection := '';
  IniKey := '';

  SpinEdit := Sender as TSpinEdit;

  // *** 在改变其他组件的值之前，先设置 FUpdating 为 True ***
  FUpdating := True;
  try
    if SpinEdit = SpinEdit1 then begin IniSection := 'CONFIG'; IniKey := 'Sys.MusicVolume'; TrackBar1.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit2 then begin IniSection := 'CONFIG'; IniKey := 'Sys.SoundVolume'; TrackBar2.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit3 then begin IniSection := 'CONFIG'; IniKey := 'Sys.FrameRate'; TrackBar3.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit4 then begin IniSection := 'CONFIG'; IniKey := 'Sys.BattleDelay'; TrackBar4.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit5 then begin IniSection := 'CONFIG'; IniKey := 'Net.PlayerNum'; TrackBar5.Position := SpinEdit.Value; UpdatePlayerWFValue; end
    else if SpinEdit = SpinEdit6 then begin IniSection := 'CONFIG'; IniKey := 'Net.PlayerWF'; TrackBar6.Position := SpinEdit.Value; UpdatePlayerNumValue; end
    else if SpinEdit = SpinEdit7 then begin IniSection := 'CONFIG'; IniKey := 'Sys.ScreenZoom'; TrackBar7.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit8 then begin IniSection := 'CONFIG'; IniKey := 'Sys.Zoom'; TrackBar8.Position := SpinEdit.Value; end
    else if SpinEdit = SpinEdit9 then begin IniSection := 'CONFIG'; IniKey := 'Net.BattleField'; end
    else if SpinEdit = SpinEdit10 then begin IniSection := 'CONFIG'; IniKey := 'Net.HostPort'; end;
  finally
    // *** 确保在所有操作完成后，将 FUpdating 设置回 False ***
    FUpdating := False;
  end;

  if IniKey <> '' then
  begin
    Val := SpinEdit.Value;
    // *** 使用智能写入方法 ***
    SmartWriteValue(IniSection, IniKey, IntToStr(Val));
  end;
end;

procedure TForm1.EditChange(Sender: TObject);
var
  Edit: TEdit;
  IniSection, IniKey: string;
begin
  if not (Sender is TEdit) then Exit;

  IniSection := '';
  IniKey := '';

  Edit := Sender as TEdit;
  if Edit = Edit1 then begin IniSection := 'CONFIG'; IniKey := 'Sys.PlayName'; end
  else if Edit = Edit2 then begin IniSection := 'CONFIG'; IniKey := 'Net.HostAddress'; end
  else if Edit = Edit3 then begin IniSection := 'CONFIG'; IniKey := 'Net.PlayerName'; end;

  if IniKey <> '' then
    // *** 使用智能写入方法 ***
    SmartWriteValue('CONFIG', IniKey, Edit.Text);
end;

procedure TForm1.ComboBoxChange(Sender: TObject);
var
  ComboBox: TComboBox;
  IniKey: string;
  Val: Integer;
  ValStr: string;
begin
  if not (Sender is TComboBox) then Exit;

  ComboBox := Sender as TComboBox;
  IniKey := '';
  ValStr := '';

  if ComboBox = ComboBox1 then begin IniKey := 'Sys.RenderMode'; Val := ComboBox.ItemIndex; ValStr := IntToStr(Val); end
  else if ComboBox = ComboBox2 then begin IniKey := 'Sys.FontName'; if (ComboBox.ItemIndex >=0) and (ComboBox.ItemIndex < Length(FFonts)) then ValStr := '"' + FFonts[ComboBox.ItemIndex].Path + '"'; end
  else if ComboBox = ComboBox3 then begin IniKey := 'Sys.Shouting'; ValStr := IntToStr(ComboBox.ItemIndex); end
  else if ComboBox = ComboBox4 then begin IniKey := 'Sys.Shoutlang'; ValStr := IntToStr(ComboBox.ItemIndex + 1); end
  else if ComboBox = ComboBox5 then begin IniKey := 'Sys.EnableJoyStick'; if ComboBox.ItemIndex = 1 then Val := 2 else Val := 0; ValStr := IntToStr(Val); end
  else if ComboBox = ComboBox6 then begin IniKey := 'Sys.FallowNum'; Val := ComboBox.ItemIndex; if Val > 0 then Val := Val + 1; ValStr := IntToStr(Val); end
  else if ComboBox = ComboBox7 then begin IniKey := 'Sys.AutoUpgrade'; ValStr := IntToStr(ComboBox.ItemIndex); end
  else if ComboBox = ComboBox8 then begin IniKey := 'Net.BattleStand'; ValStr := IntToStr(ComboBox.ItemIndex); end
  else if ComboBox = ComboBox9 then
  begin
    IniKey := 'Net.BattleSelect';
    ValStr := IntToStr(ComboBox.ItemIndex + 1);
    // --- 新增代码：根据 ComboBox9 的值设置 SpinEdit9 的 Enabled 属性 ---
    SpinEdit9.Enabled := (ComboBox.ItemIndex = 15);
  end
  else if ComboBox = ComboBox10 then begin IniKey := 'Sys.TouchSwitch'; ValStr := IntToStr(ComboBox.ItemIndex); end // 新增：触屏切换
  else if ComboBox = ComboBox11 then begin IniKey := 'Sys.MenuStyle'; ValStr := IntToStr(ComboBox.ItemIndex); end   // 新增：菜单风格
  else if ComboBox = ComboBox12 then begin IniKey := 'Sys.MenuSelectBox'; ValStr := IntToStr(ComboBox.ItemIndex); end; // 新增：菜单模式

  if (IniKey <> '') and (ValStr <> '') then
    // *** 使用智能写入方法 ***
    SmartWriteValue('CONFIG', IniKey, ValStr);
end;

procedure TForm1.UpdatePlayerWFValue;
var
  PlayerNum: Integer;
begin
  PlayerNum := TrackBar5.Position;
  if TrackBar6.Position >= PlayerNum then
  begin
    TrackBar6.Position := PlayerNum - 1;
    SpinEdit6.Value := TrackBar6.Position;
  end;
  if TrackBar6.Position < TrackBar6.Min then
  begin
    TrackBar6.Position := TrackBar6.Min;
    SpinEdit6.Value := TrackBar6.Position;
  end;
end;

procedure TForm1.UpdatePlayerNumValue;
var
  PlayerWF: Integer;
begin
  PlayerWF := TrackBar6.Position;
  if TrackBar5.Position <= PlayerWF then
  begin
    TrackBar5.Position := PlayerWF + 1;
    SpinEdit5.Value := TrackBar5.Position;
  end;
  if TrackBar5.Position > TrackBar5.Max then
  begin
    TrackBar5.Position := TrackBar5.Max;
    SpinEdit5.Value := TrackBar5.Position;
  end;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
  // 打开网页，网址：https://bbs.3dmgame.com/forum-3779-1.html
  OpenURL('https://bbs.3dmgame.com/forum-3779-1.html');
end;

procedure TForm1.Image2MouseEnter(Sender: TObject);
var
  Stream: TResourceStream;
begin
  // 从资源中加载名为 'FORUM1_PNG' 的图片，这是鼠标悬停的图片
  Stream := TResourceStream.Create(HInstance, 'FORUM1', RT_RCDATA);
  try
    Image2.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TForm1.Image2MouseLeave(Sender: TObject);
var
  Stream: TResourceStream;
begin
  // 从资源中加载名为 'FORUM2_PNG' 的图片，这是鼠标离开的图片
  Stream := TResourceStream.Create(HInstance, 'FORUM2', RT_RCDATA);
  try
    Image2.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TForm1.Image3Click(Sender: TObject);
var
  Process: TProcess;
  FilePath: string;
begin
  // 添加跨平台游戏启动
  FilePath := ExtractFilePath(ParamStr(0));

  Process := TProcess.Create(nil);
  try
    // 根据操作系统选择要执行的文件
    {$ifdef WINDOWS}
    Process.Executable := IncludeTrailingPathDelimiter(FilePath) + '逐梦江湖行.exe';
    {$endif}
    {$ifdef DARWIN}
    // 设置 TProcess 参数
    Process.Executable := '/usr/bin/open';
    FilePath := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExtractFileDir(FilePath))));//单纯二进制不需要，app才需要

    // 拼接出要打开的应用的完整路径
    Process.Parameters.Add(IncludeTrailingPathDelimiter(FilePath) + '逐梦江湖行.app');
    {$endif}
    {$ifdef LINUX}
    Process.Executable := IncludeTrailingPathDelimiter(FilePath) + 'dream'; // Linux 可执行文件通常没有扩展名
    {$endif}

    // 检查文件是否存在（macOS 需要检查目录是否存在）
    {$ifdef DARWIN}
    if DirectoryExists(IncludeTrailingPathDelimiter(FilePath) + '逐梦江湖行.app') then
    {$else}
    if FileExists(Process.Executable) then
    {$endif}
    begin
      Process.Execute;
      // 启动游戏后立即关闭本程序
      Application.Terminate;
    end
    else
    begin
      {$ifdef DARWIN}
      ShowMessage('未找到游戏应用程序：' + IncludeTrailingPathDelimiter(FilePath) + '逐梦江湖行.app');
      {$else}
      ShowMessage('未找到游戏可执行文件：' + Process.Executable);
      {$endif}
    end;

  finally
    Process.Free;
  end;
end;


procedure TForm1.Image3MouseEnter(Sender: TObject);
var
  Stream: TResourceStream;
begin
  // 从资源中加载名为 'GAME_START1_PNG' 的图片
  Stream := TResourceStream.Create(HInstance, 'GAME1', RT_RCDATA);
  try
    Image3.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TForm1.Image3MouseLeave(Sender: TObject);
var
  Stream: TResourceStream;
begin
  // 从资源中加载名为 'GAME_START2_PNG' 的图片
  Stream := TResourceStream.Create(HInstance, 'GAME2', RT_RCDATA);
  try
    Image3.Picture.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TForm1.RadioButton1Change(Sender: TObject);
begin
end;

procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
end;

procedure TForm1.StaticText1Click(Sender: TObject);
begin
  OpenURL('https://qm.qq.com/cgi-bin/qm/qr?k=5RxtqrvERhllrn2yf4c6ps-53DUdkNhd&jump_from=webapi&authKey=zX/qFZcQqb9OdbYfPR2UWq0aDRdqXeDGwX/dYOFaZUC1jrR7jzDq8nZW8BnEn2cm');
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
end;

end.
