-----------------------------------------------------------------------------------
--!     @file    axi4_core.vhd
--!     @brief   AXI4 Dummy Plug Core Package.
--!     @version 1.2.0
--!     @date    2012/10/27
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.CORE_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_REQ_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_ACK_VECTOR;
use     DUMMY_PLUG.READER.EVENT_TYPE;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug のコアパッケージ.
-----------------------------------------------------------------------------------
package AXI4_CORE is
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネルのタイプ.
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_TYPE is (
        AXI4_CHANNEL_AR,
        AXI4_CHANNEL_AW,
        AXI4_CHANNEL_R,
        AXI4_CHANNEL_W,
        AXI4_CHANNEL_B,
        AXI4_CHANNEL_M
    );
    -------------------------------------------------------------------------------
    --! @brief WAITオペレーション実行時のデフォルトのタイムアウトクロック数
    -------------------------------------------------------------------------------
    constant  DEFAULT_WAIT_TIMEOUT : integer := 10000;
    -------------------------------------------------------------------------------
    --! @brief AXI4 トランザクションデータの最大バイト数.
    -------------------------------------------------------------------------------
    constant  AXI4_XFER_MAX_BYTES  : integer := 1024;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_A_CHANNEL_SIGNAL_TYPE is record
        ADDR     : std_logic_vector(AXI4_ADDR_MAX_WIDTH -1 downto 0);
        WRITE    : std_logic;
        LEN      : AXI4_ALEN_TYPE;
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : AXI4_ALOCK_TYPE;
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        QOS      : AXI4_AQOS_TYPE;
        REGION   : AXI4_AREGION_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH -1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH   -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_A_CHANNEL_SIGNAL_DONTCARE : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '-'),
        WRITE   => '-',
        LEN     => (others => '-'),
        SIZE    => (others => '-'),
        BURST   => (others => '-'),
        LOCK    => (others => '-'),
        CACHE   => (others => '-'),
        PROT    => (others => '-'),
        QOS     => (others => '-'),
        REGION  => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 アドレスチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_A_CHANNEL_SIGNAL_NULL     : AXI4_A_CHANNEL_SIGNAL_TYPE := (
        ADDR    => (others => '0'),
        WRITE   => '0',
        LEN     => (others => '0'),
        SIZE    => (others => '0'),
        BURST   => (others => '0'),
        LOCK    => (others => '0'),
        CACHE   => (others => '0'),
        PROT    => (others => '0'),
        QOS     => (others => '0'),
        REGION  => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_R_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        RESP     : AXI4_RESP_TYPE;
        LAST     : std_logic;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_R_CHANNEL_SIGNAL_DONTCARE : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        RESP    => (others => '-'),
        LAST    => '-',
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 リードチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_R_CHANNEL_SIGNAL_NULL     : AXI4_R_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        RESP    => (others => '0'),
        LAST    => '0',
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_W_CHANNEL_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        LAST     : std_logic;
        STRB     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_W_CHANNEL_SIGNAL_DONTCARE : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        LAST    => '-',
        STRB    => (others => '-'),
        USER    => (others => '-'),
        ID      => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライトチャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_W_CHANNEL_SIGNAL_NULL     : AXI4_W_CHANNEL_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        LAST    => '0',
        STRB    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_B_CHANNEL_SIGNAL_TYPE is record
        RESP     : AXI4_RESP_TYPE;
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_B_CHANNEL_SIGNAL_DONTCARE : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '-'),
        ID      => (others => '-'),
        USER    => (others => '-'),
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_B_CHANNEL_SIGNAL_NULL     : AXI4_B_CHANNEL_SIGNAL_TYPE := (
        RESP    => (others => '0'),
        USER    => (others => '0'),
        ID      => (others => '0'),
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_CHANNEL_SIGNAL_TYPE is record
        AR       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        R        : AXI4_R_CHANNEL_SIGNAL_TYPE;
        AW       : AXI4_A_CHANNEL_SIGNAL_TYPE;
        W        : AXI4_W_CHANNEL_SIGNAL_TYPE;
        B        : AXI4_B_CHANNEL_SIGNAL_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_CHANNEL_SIGNAL_DONTCARE : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        R       => AXI4_R_CHANNEL_SIGNAL_DONTCARE,
        AW      => AXI4_A_CHANNEL_SIGNAL_DONTCARE,
        W       => AXI4_W_CHANNEL_SIGNAL_DONTCARE,
        B       => AXI4_B_CHANNEL_SIGNAL_DONTCARE
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4 チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_CHANNEL_SIGNAL_NULL     : AXI4_CHANNEL_SIGNAL_TYPE := (
        AR      => AXI4_A_CHANNEL_SIGNAL_NULL,
        R       => AXI4_R_CHANNEL_SIGNAL_NULL,
        AW      => AXI4_A_CHANNEL_SIGNAL_NULL,
        W       => AXI4_W_CHANNEL_SIGNAL_NULL,
        B       => AXI4_B_CHANNEL_SIGNAL_NULL
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_TRANSACTION_SIGNAL_TYPE is record
        VALID    : std_logic;
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH    -1 downto 0);
        ADDR     : std_logic_vector(AXI4_ADDR_MAX_WIDTH  -1 downto 0);
        AUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        DUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        BUSER    : std_logic_vector(AXI4_USER_MAX_WIDTH  -1 downto 0);
        DATA     : std_logic_vector(AXI4_XFER_MAX_BYTES*8-1 downto 0);
        DATA_LEN : integer;
        WRITE    : std_logic;
        LEN      : AXI4_ALEN_TYPE;
        SIZE     : AXI4_ASIZE_TYPE;
        BURST    : AXI4_ABURST_TYPE;
        LOCK     : AXI4_ALOCK_TYPE;
        CACHE    : AXI4_ACACHE_TYPE;
        PROT     : AXI4_APROT_TYPE;
        QOS      : AXI4_AQOS_TYPE;
        REGION   : AXI4_AREGION_TYPE;
        RESP     : AXI4_RESP_TYPE;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_TRANSACTION_SIGNAL_NULL     : AXI4_TRANSACTION_SIGNAL_TYPE := (
        VALID    => '0'              ,
        ID       => (others => '0')  ,
        ADDR     => (others => '0')  ,
        AUSER    => (others => '0')  ,
        DUSER    => (others => '0')  ,
        BUSER    => (others => '0')  ,
        DATA     => (others => '0')  ,
        DATA_LEN =>  0               ,
        WRITE    => '0'              ,
        LEN      => (others => '0')  ,
        SIZE     => (others => '0')  ,
        BURST    => (others => '0')  ,
        LOCK     => (others => '0')  ,
        CACHE    => (others => '0')  ,
        PROT     => (others => '0')  ,
        QOS      => (others => '0')  ,
        REGION   => (others => '0')  ,
        RESP     => (others => '0')
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4トランザクション信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_TRANSACTION_SIGNAL_DONTCARE : AXI4_TRANSACTION_SIGNAL_TYPE := (
        VALID    => '-'              ,
        ID       => (others => '-')  ,
        ADDR     => (others => '-')  ,
        AUSER    => (others => '-')  ,
        DUSER    => (others => '-')  ,
        BUSER    => (others => '-')  ,
        DATA     => (others => '-')  ,
        DATA_LEN =>  0               ,
        WRITE    => '-'              ,
        LEN      => (others => '-')  ,
        SIZE     => (others => '-')  ,
        BURST    => (others => '-')  ,
        LOCK     => (others => '-')  ,
        CACHE    => (others => '-')  ,
        PROT     => (others => '-')  ,
        QOS      => (others => '-')  ,
        REGION   => (others => '-')  ,
        RESP     => (others => '-')
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream 信号のレコード宣言.
    -------------------------------------------------------------------------------
    type      AXI4_STREAM_SIGNAL_TYPE is record
        DATA     : std_logic_vector(AXI4_DATA_MAX_WIDTH-1 downto 0);
        KEEP     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        STRB     : std_logic_vector(AXI4_STRB_MAX_WIDTH-1 downto 0);
        USER     : std_logic_vector(AXI4_USER_MAX_WIDTH-1 downto 0);
        DEST     : std_logic_vector(AXI4_DEST_MAX_WIDTH-1 downto 0);
        ID       : std_logic_vector(AXI4_ID_MAX_WIDTH  -1 downto 0);
        LAST     : std_logic;
        VALID    : std_logic;
        READY    : std_logic;
    end record;
    -------------------------------------------------------------------------------
    --! @brief AXI4-Stream信号のドントケア定数.
    -------------------------------------------------------------------------------
    constant  AXI4_STREAM_SIGNAL_DONTCARE : AXI4_STREAM_SIGNAL_TYPE := (
        DATA    => (others => '-'),
        KEEP    => (others => '-'),
        STRB    => (others => '-'),
        USER    => (others => '-'),
        DEST    => (others => '-'),
        ID      => (others => '-'),
        LAST    => '-',
        VALID   => '-',
        READY   => '-'
    );        
    -------------------------------------------------------------------------------
    --! @brief AXI4 ライト応答チャネル信号のNULL定数.
    -------------------------------------------------------------------------------
    constant  AXI4_STREAM_SIGNAL_NULL     : AXI4_STREAM_SIGNAL_TYPE := (
        DATA    => (others => '0'),
        KEEP    => (others => '0'),
        STRB    => (others => '0'),
        USER    => (others => '0'),
        DEST    => (others => '0'),
        ID      => (others => '0'),
        LAST    => '0',
        VALID   => '0',
        READY   => '0'
    );        
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからチャネル信号レコードの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    CHANNEL     チャネルのタイプ.
    --! @param    READ        リード可/不可を指定.
    --! @param    WRITE       ライト可/不可を指定.
    --! @param    WIDTH       チャネル信号のビット幅を指定する.
    --! @param    SIGNALS     読み取った値が入るレコード変数. inoutであることに注意.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_CHANNEL(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  CHANNEL       : in    AXI4_CHANNEL_TYPE;
                  READ          : in    boolean;
                  WRITE         : in    boolean;
                  WIDTH         : in    AXI4_SIGNAL_WIDTH_TYPE;
                  SIGNALS       : inout AXI4_CHANNEL_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからAXI4-Stream信号構造体の値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    WIDTH       AXI4-Stream信号のビット幅を指定する.
    --! @param    SIGNALS     読み取った値が入るレコード変数. inoutであることに注意.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_STREAM(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  WIDTH         : in    AXI4_STREAM_SIGNAL_WIDTH_TYPE;
                  SIGNALS       : inout AXI4_STREAM_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからトランザクションの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    ADDR_WIDTH  アドレスチャネルのビット幅.
    --! @param    AUSER_WIDTH ユーザー信号のビット幅.
    --! @param    DUSER_WIDTH ユーザー信号のビット幅.
    --! @param    BUSER_WIDTH ユーザー信号のビット幅.
    --! @param    ID_WIDTH    ID信号のビット幅.
    --! @param    TRANS       トランザクション信号.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_TRANSACTION(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  ADDR_WIDTH    : in    integer;
                  AUSER_WIDTH   : in    integer;
                  DUSER_WIDTH   : in    integer;
                  BUSER_WIDTH   : in    integer;
                  ID_WIDTH      : in    integer;
                  TRANS         : inout AXI4_TRANSACTION_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    );
    -------------------------------------------------------------------------------
    --! @brief トランザクション情報からアドレスの下位ビットと１ワードのバイト数を生成
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    TRANS       トランザクション情報.
    --! @param    ADDR        アドレスの下位ビットの整数値.
    --! @param    SIZE        １ワードのバイト数.
    -------------------------------------------------------------------------------
    procedure TRANSACTION_TO_ADDR_AND_BYTES(
                  TRANS         : in    AXI4_TRANSACTION_SIGNAL_TYPE;
                  ADDR          : out   integer;
                  SIZE          : out   integer
    );
    -------------------------------------------------------------------------------
    --! @brief AXI4_CHANNEL_PLAYER
    -------------------------------------------------------------------------------
    component  AXI4_CHANNEL_PLAYER is
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic (
            SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                              STRING;
            NAME            : --! @brief 固有名詞.
                              STRING;
            FULL_NAME       : --! @brief メッセージ出力用の固有名詞.
                              STRING;
            CHANNEL         : --! @brief チャネルタイプ.
                              AXI4_CHANNEL_TYPE;
            MASTER          : --! @brief マスターモードを指定する.
                              boolean   := FALSE;
            SLAVE           : --! @brief スレーブモードを指定する.
                              boolean   := FALSE;
            READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                              boolean   := TRUE;
            WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                              boolean   := TRUE;
            OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                              time;
            WIDTH           : --! @brief AXI4 IS WIDTH :
                              AXI4_SIGNAL_WIDTH_TYPE;
            SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                              integer :=  1;
            SYNC_LOCAL_WAIT : --! @brief ローカル同期時のウェイトクロック数.
                              integer := 2;
            GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                              integer := 8;
            GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                              integer := 8;
            FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                              --!        アボートするかどうかを指定するフラグ.
                              boolean := true
        );
        --------------------------------------------------------------------------
        -- 入出力ポートの定義.
        --------------------------------------------------------------------------
        port(
            ----------------------------------------------------------------------
            -- グローバルシグナル.
            ----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            ----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            ----------------------------------------------------------------------
            ARADDR_I        : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
            ARADDR_O        : out   std_logic_vector(WIDTH.ARADDR -1 downto 0);
            ARLEN_I         : in    AXI4_ALEN_TYPE;
            ARLEN_O         : out   AXI4_ALEN_TYPE;
            ARSIZE_I        : in    AXI4_ASIZE_TYPE;
            ARSIZE_O        : out   AXI4_ASIZE_TYPE;
            ARBURST_I       : in    AXI4_ABURST_TYPE;
            ARBURST_O       : out   AXI4_ABURST_TYPE;
            ARLOCK_I        : in    AXI4_ALOCK_TYPE;
            ARLOCK_O        : out   AXI4_ALOCK_TYPE;
            ARCACHE_I       : in    AXI4_ACACHE_TYPE;
            ARCACHE_O       : out   AXI4_ACACHE_TYPE;
            ARPROT_I        : in    AXI4_APROT_TYPE;
            ARPROT_O        : out   AXI4_APROT_TYPE;
            ARQOS_I         : in    AXI4_AQOS_TYPE;
            ARQOS_O         : out   AXI4_AQOS_TYPE;
            ARREGION_I      : in    AXI4_AREGION_TYPE;
            ARREGION_O      : out   AXI4_AREGION_TYPE;
            ARUSER_I        : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
            ARUSER_O        : out   std_logic_vector(WIDTH.ARUSER -1 downto 0);
            ARID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            ARID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            ARVALID_I       : in    std_logic;
            ARVALID_O       : out   std_logic;
            ARREADY_I       : in    std_logic;
            ARREADY_O       : out   std_logic;
            ----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            ----------------------------------------------------------------------
            RVALID_I        : in    std_logic;
            RVALID_O        : out   std_logic;
            RLAST_I         : in    std_logic;
            RLAST_O         : out   std_logic;
            RDATA_I         : in    std_logic_vector(WIDTH.RDATA  -1 downto 0);
            RDATA_O         : out   std_logic_vector(WIDTH.RDATA  -1 downto 0);
            RRESP_I         : in    AXI4_RESP_TYPE;
            RRESP_O         : out   AXI4_RESP_TYPE;
            RUSER_I         : in    std_logic_vector(WIDTH.RUSER  -1 downto 0);
            RUSER_O         : out   std_logic_vector(WIDTH.RUSER  -1 downto 0);
            RID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            RID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            RREADY_I        : in    std_logic;
            RREADY_O        : out   std_logic;
            ----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            ----------------------------------------------------------------------
            AWADDR_I        : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
            AWADDR_O        : out   std_logic_vector(WIDTH.AWADDR -1 downto 0);
            AWLEN_I         : in    AXI4_ALEN_TYPE;
            AWLEN_O         : out   AXI4_ALEN_TYPE;
            AWSIZE_I        : in    AXI4_ASIZE_TYPE;
            AWSIZE_O        : out   AXI4_ASIZE_TYPE;
            AWBURST_I       : in    AXI4_ABURST_TYPE;
            AWBURST_O       : out   AXI4_ABURST_TYPE;
            AWLOCK_I        : in    AXI4_ALOCK_TYPE;
            AWLOCK_O        : out   AXI4_ALOCK_TYPE;
            AWCACHE_I       : in    AXI4_ACACHE_TYPE;
            AWCACHE_O       : out   AXI4_ACACHE_TYPE;
            AWPROT_I        : in    AXI4_APROT_TYPE;
            AWPROT_O        : out   AXI4_APROT_TYPE;
            AWQOS_I         : in    AXI4_AQOS_TYPE;
            AWQOS_O         : out   AXI4_AQOS_TYPE;
            AWREGION_I      : in    AXI4_AREGION_TYPE;
            AWREGION_O      : out   AXI4_AREGION_TYPE;
            AWUSER_I        : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
            AWUSER_O        : out   std_logic_vector(WIDTH.AWUSER -1 downto 0);
            AWID_I          : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            AWID_O          : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            AWVALID_I       : in    std_logic;
            AWVALID_O       : out   std_logic;
            AWREADY_I       : in    std_logic;
            AWREADY_O       : out   std_logic;
            ----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            ----------------------------------------------------------------------
            WLAST_I         : in    std_logic;
            WLAST_O         : out   std_logic;
            WDATA_I         : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
            WDATA_O         : out   std_logic_vector(WIDTH.WDATA  -1 downto 0);
            WSTRB_I         : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
            WSTRB_O         : out   std_logic_vector(WIDTH.WDATA/8-1 downto 0);
            WUSER_I         : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
            WUSER_O         : out   std_logic_vector(WIDTH.WUSER  -1 downto 0);
            WID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            WID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            WVALID_I        : in    std_logic;
            WVALID_O        : out   std_logic;
            WREADY_I        : in    std_logic;
            WREADY_O        : out   std_logic;
            ----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            ----------------------------------------------------------------------
            BRESP_I         : in    AXI4_RESP_TYPE;
            BRESP_O         : out   AXI4_RESP_TYPE;
            BUSER_I         : in    std_logic_vector(WIDTH.BUSER  -1 downto 0);
            BUSER_O         : out   std_logic_vector(WIDTH.BUSER  -1 downto 0);
            BID_I           : in    std_logic_vector(WIDTH.ID     -1 downto 0);
            BID_O           : out   std_logic_vector(WIDTH.ID     -1 downto 0);
            BVALID_I        : in    std_logic;
            BVALID_O        : out   std_logic;
            BREADY_I        : in    std_logic;
            BREADY_O        : out   std_logic;
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        : out   SYNC_REQ_VECTOR(SYNC_WIDTH-1 downto 0);
            SYNC_ACK        : in    SYNC_ACK_VECTOR(SYNC_WIDTH-1 downto 0) := (others => '0');
            SYNC_LOCAL_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
            SYNC_LOCAL_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
            SYNC_TRANS_REQ  : out   SYNC_REQ_VECTOR(0 downto 0);
            SYNC_TRANS_ACK  : in    SYNC_ACK_VECTOR(0 downto 0);
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I          : in    AXI4_TRANSACTION_SIGNAL_TYPE;
            TRAN_O          : out   AXI4_TRANSACTION_SIGNAL_TYPE;
            -----------------------------------------------------------------------
            -- GPIO
            -----------------------------------------------------------------------
            GPI             : in    std_logic_vector(GPI_WIDTH     -1 downto 0) := (others => '0');
            GPO             : out   std_logic_vector(GPO_WIDTH     -1 downto 0);
            -----------------------------------------------------------------------
            -- 各種状態信号.
            -----------------------------------------------------------------------
            REPORT_STATUS   : out   REPORT_STATUS_TYPE;
            FINISH          : out   std_logic
        );
    end component;
end     AXI4_CORE;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.READER.all;
use     DUMMY_PLUG.VOCAL.all;
use     DUMMY_PLUG.UTIL.STRING_TO_STD_LOGIC_VECTOR;
use     DUMMY_PLUG.UTIL.MATCH_STD_LOGIC;
use     DUMMY_PLUG.UTIL.BIN_TO_STRING;
use     DUMMY_PLUG.UTIL.HEX_TO_STRING;
use     DUMMY_PLUG.UTIL.INTEGER_TO_STRING;
-----------------------------------------------------------------------------------
--! @brief AXI4 Dummy Plug のコアパッケージ本体.
-----------------------------------------------------------------------------------
package body AXI4_CORE is
    -------------------------------------------------------------------------------
    --! @brief 信号名の定義.
    -------------------------------------------------------------------------------
    subtype   KEY_TYPE     is STRING(1 to 7);

    constant  KEY_ADDR      : KEY_TYPE := "ADDR   ";
    constant  KEY_WRITE     : KEY_TYPE := "WRITE  ";
    constant  KEY_LEN       : KEY_TYPE := "LEN    ";
    constant  KEY_SIZE      : KEY_TYPE := "SIZE   ";
    constant  KEY_BURST     : KEY_TYPE := "BURST  ";
    constant  KEY_LOCK      : KEY_TYPE := "LOCK   ";
    constant  KEY_CACHE     : KEY_TYPE := "CACHE  ";
    constant  KEY_PROT      : KEY_TYPE := "PROT   ";
    constant  KEY_QOS       : KEY_TYPE := "QOS    ";
    constant  KEY_REGION    : KEY_TYPE := "REGION ";
    constant  KEY_USER      : KEY_TYPE := "USER   ";
    constant  KEY_ID        : KEY_TYPE := "ID     ";
    constant  KEY_DATA      : KEY_TYPE := "DATA   ";
    constant  KEY_RESP      : KEY_TYPE := "RESP   ";
    constant  KEY_LAST      : KEY_TYPE := "LAST   ";
    constant  KEY_KEEP      : KEY_TYPE := "KEEP   ";
    constant  KEY_DEST      : KEY_TYPE := "DEST   ";
    constant  KEY_STRB      : KEY_TYPE := "STRB   ";
    constant  KEY_VALID     : KEY_TYPE := "VALID  ";
    constant  KEY_READY     : KEY_TYPE := "READY  ";

    constant  KEY_AWRITE    : KEY_TYPE := "AWRITE ";
    constant  KEY_ALEN      : KEY_TYPE := "ALEN   ";
    constant  KEY_ASIZE     : KEY_TYPE := "ASIZE  ";
    constant  KEY_ABURST    : KEY_TYPE := "ABURST ";
    constant  KEY_ALOCK     : KEY_TYPE := "ALOCK  ";
    constant  KEY_ACACHE    : KEY_TYPE := "ACACHE ";
    constant  KEY_APROT     : KEY_TYPE := "APROT  ";
    constant  KEY_AQOS      : KEY_TYPE := "AQOS   ";
    constant  KEY_AREGION   : KEY_TYPE := "AREGION";
    constant  KEY_AUSER     : KEY_TYPE := "AUSER  ";
    constant  KEY_AID       : KEY_TYPE := "AID    ";
    constant  KEY_AVALID    : KEY_TYPE := "AVALID ";
    constant  KEY_AREADY    : KEY_TYPE := "AREADY ";
    
    constant  KEY_AWADDR    : KEY_TYPE := "AWADDR ";
    constant  KEY_AWLEN     : KEY_TYPE := "AWLEN  ";
    constant  KEY_AWSIZE    : KEY_TYPE := "AWSIZE ";
    constant  KEY_AWBURST   : KEY_TYPE := "AWBURST";
    constant  KEY_AWLOCK    : KEY_TYPE := "AWLOCK ";
    constant  KEY_AWCACHE   : KEY_TYPE := "AWCACHE";
    constant  KEY_AWPROT    : KEY_TYPE := "AWPROT ";
    constant  KEY_AWQOS     : KEY_TYPE := "AWQOS  ";
    constant  KEY_AWUSER    : KEY_TYPE := "AWUSER ";
    constant  KEY_AWREGION  : KEY_TYPE := "AWREGIO";
    constant  KEY_AWID      : KEY_TYPE := "AWID   ";
    constant  KEY_AWVALID   : KEY_TYPE := "AWVALID";
    constant  KEY_AWREADY   : KEY_TYPE := "AWREADY";
    
    constant  KEY_ARADDR    : KEY_TYPE := "ARADDR ";
    constant  KEY_ARLEN     : KEY_TYPE := "ARLEN  ";
    constant  KEY_ARSIZE    : KEY_TYPE := "ARSIZE ";
    constant  KEY_ARBURST   : KEY_TYPE := "ARBURST";
    constant  KEY_ARLOCK    : KEY_TYPE := "ARLOCK ";
    constant  KEY_ARCACHE   : KEY_TYPE := "ARCACHE";
    constant  KEY_ARPROT    : KEY_TYPE := "ARPROT ";
    constant  KEY_ARQOS     : KEY_TYPE := "ARQOS  ";
    constant  KEY_ARUSER    : KEY_TYPE := "ARUSER ";
    constant  KEY_ARREGION  : KEY_TYPE := "ARREGIO";
    constant  KEY_ARID      : KEY_TYPE := "ARID   ";
    constant  KEY_ARVALID   : KEY_TYPE := "ARVALID";
    constant  KEY_ARREADY   : KEY_TYPE := "ARREADY";
    
    constant  KEY_RDATA     : KEY_TYPE := "RDATA  ";
    constant  KEY_RRESP     : KEY_TYPE := "RRESP  ";
    constant  KEY_RLAST     : KEY_TYPE := "RLAST  ";
    constant  KEY_RUSER     : KEY_TYPE := "RUSER  ";
    constant  KEY_RID       : KEY_TYPE := "RID    ";
    constant  KEY_RVALID    : KEY_TYPE := "RVALID ";
    constant  KEY_RREADY    : KEY_TYPE := "RREADY ";

    constant  KEY_WDATA     : KEY_TYPE := "WDATA  ";
    constant  KEY_WSTRB     : KEY_TYPE := "WSTRB  ";
    constant  KEY_WLAST     : KEY_TYPE := "WLAST  ";
    constant  KEY_WUSER     : KEY_TYPE := "WUSER  ";
    constant  KEY_WID       : KEY_TYPE := "WID    ";
    constant  KEY_WVALID    : KEY_TYPE := "WVALID ";
    constant  KEY_WREADY    : KEY_TYPE := "WREADY ";

    constant  KEY_BRESP     : KEY_TYPE := "BRESP  ";
    constant  KEY_BUSER     : KEY_TYPE := "BUSER  ";
    constant  KEY_BID       : KEY_TYPE := "BID    ";
    constant  KEY_BVALID    : KEY_TYPE := "BVALID ";
    constant  KEY_BREADY    : KEY_TYPE := "BREADY ";

    constant  KEY_TDATA     : KEY_TYPE := "TDATA  ";
    constant  KEY_TSTRB     : KEY_TYPE := "TSTRB  ";
    constant  KEY_TKEEP     : KEY_TYPE := "TKEEP  ";
    constant  KEY_TLAST     : KEY_TYPE := "TLAST  ";
    constant  KEY_TUSER     : KEY_TYPE := "TUSER  ";
    constant  KEY_TDEST     : KEY_TYPE := "TDEST  ";
    constant  KEY_TID       : KEY_TYPE := "TID    ";
    constant  KEY_TVALID    : KEY_TYPE := "TVALID ";
    constant  KEY_TREADY    : KEY_TYPE := "TREADY ";

    constant  KEY_DUSER     : KEY_TYPE := "DUSER  ";
    constant  KEY_OKAY      : KEY_TYPE := "OKAY   ";
    constant  KEY_EXOKAY    : KEY_TYPE := "EXOKAY ";
    constant  KEY_SLVERR    : KEY_TYPE := "SLVERR ";
    constant  KEY_DECERR    : KEY_TYPE := "DECERR ";
    constant  KEY_FIXED     : KEY_TYPE := "FIXED  ";
    constant  KEY_INCR      : KEY_TYPE := "INCR   ";
    constant  KEY_WRAP      : KEY_TYPE := "WRAP   ";
    constant  KEY_RESV      : KEY_TYPE := "RESV   ";

    -------------------------------------------------------------------------------
    --! @brief READERから読み取る信号の種類を示すタイプの定義.
    -------------------------------------------------------------------------------
    type      READ_AXI4_SIGNAL_TYPE is (
              READ_NONE     ,
              READ_ARADDR   ,
              READ_ARSIZE   ,
              READ_ARLEN    ,
              READ_ARBURST  ,
              READ_ARLOCK   ,
              READ_ARCACHE  ,
              READ_ARPROT   ,
              READ_ARQOS    ,
              READ_ARREGION ,
              READ_ARUSER   ,
              READ_ARID     ,
              READ_ARVALID  ,
              READ_ARREADY  ,
              READ_AWADDR   ,
              READ_AWSIZE   ,
              READ_AWLEN    ,
              READ_AWBURST  ,
              READ_AWLOCK   ,
              READ_AWCACHE  ,
              READ_AWPROT   ,
              READ_AWQOS    ,
              READ_AWREGION ,
              READ_AWUSER   ,
              READ_AWID     ,
              READ_AWVALID  ,
              READ_AWREADY  ,
              READ_RDATA    ,
              READ_RRESP    ,
              READ_RLAST    ,
              READ_RUSER    ,
              READ_RID      ,
              READ_RVALID   ,
              READ_RREADY   ,
              READ_WDATA    ,
              READ_WSTRB    ,
              READ_WLAST    ,
              READ_WUSER    ,
              READ_WID      ,
              READ_WVALID   ,
              READ_WREADY   ,
              READ_BRESP    ,
              READ_BUSER    ,
              READ_BID      ,
              READ_BVALID   ,
              READ_BREADY   ,
              READ_TDATA    ,
              READ_TSTRB    ,
              READ_TKEEP    ,
              READ_TLAST    ,
              READ_TUSER    ,
              READ_TDEST    ,
              READ_TID      ,
              READ_TVALID   ,
              READ_TREADY   
    );
    -------------------------------------------------------------------------------
    --! @brief KEY_WORD から READ_AXI4_SIGNAL_TYPEに変換する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    KEY_WORD    キーワード.
    --! @param    CHANNEL     チャネルのタイプ.
    --! @param    R           リード可/不可を指定.
    --! @param    W           ライト可/不可を指定.
    --! @return               変換されたREAD_AXI4_SIGNAL_TYPE.
    -------------------------------------------------------------------------------
    function  to_read_axi4_channel_signal(
                  KEY_WORD   : KEY_TYPE;
                  CHANNEL    : AXI4_CHANNEL_TYPE;
                  R,W        : boolean
    ) return READ_AXI4_SIGNAL_TYPE is
    begin
        if (W and not R) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others           => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN;   
                when KEY_AWSIZE              => return READ_AWSIZE;  
                when KEY_AWBURST             => return READ_AWBURST; 
                when KEY_AWLOCK              => return READ_AWLOCK;  
                when KEY_AWCACHE             => return READ_AWCACHE; 
                when KEY_AWPROT              => return READ_AWPROT;  
                when KEY_AWQOS               => return READ_AWQOS;   
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;  
                when KEY_AWID                => return READ_AWID;    
                when KEY_AWVALID             => return READ_AWVALID; 
                when KEY_AWREADY             => return READ_AWREADY; 
                when KEY_ALEN                => return READ_AWLEN;   
                when KEY_ASIZE               => return READ_AWSIZE;  
                when KEY_ABURST              => return READ_AWBURST; 
                when KEY_ALOCK               => return READ_AWLOCK;  
                when KEY_ACACHE              => return READ_AWCACHE; 
                when KEY_APROT               => return READ_AWPROT;  
                when KEY_AQOS                => return READ_AWQOS;   
                when KEY_AREGION             => return READ_AWREGION;
                when KEY_AUSER               => return READ_AWUSER;  
                when KEY_AID                 => return READ_AWID;    
                when KEY_AVALID              => return READ_AWVALID; 
                when KEY_AREADY              => return READ_AWREADY; 
                when KEY_WDATA               => return READ_WDATA;  
                when KEY_WSTRB               => return READ_WSTRB;  
                when KEY_WLAST               => return READ_WLAST;  
                when KEY_WUSER               => return READ_WUSER;  
                when KEY_WID                 => return READ_WID;    
                when KEY_WVALID              => return READ_WVALID; 
                when KEY_WREADY              => return READ_WREADY; 
                when KEY_BRESP               => return READ_BRESP;  
                when KEY_BUSER               => return READ_BUSER;  
                when KEY_BID                 => return READ_BID;    
                when KEY_BVALID              => return READ_BVALID; 
                when KEY_BREADY              => return READ_BREADY; 
                when others                  => null;
            end case;
        elsif (R and not W) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;  
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARVALID; 
                        when AXI4_CHANNEL_R  => return READ_RVALID; 
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREADY; 
                        when AXI4_CHANNEL_R  => return READ_RREADY; 
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARADDR;
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLEN;
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;  
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;  
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;   
                when KEY_ARLEN               => return READ_ARLEN;   
                when KEY_ARSIZE              => return READ_ARSIZE;  
                when KEY_ARBURST             => return READ_ARBURST; 
                when KEY_ARLOCK              => return READ_ARLOCK;  
                when KEY_ARCACHE             => return READ_ARCACHE; 
                when KEY_ARPROT              => return READ_ARPROT;  
                when KEY_ARQOS               => return READ_ARQOS;   
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;  
                when KEY_ARID                => return READ_ARID;    
                when KEY_ARVALID             => return READ_ARVALID; 
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_ALEN                => return READ_ARLEN;   
                when KEY_ASIZE               => return READ_ARSIZE;  
                when KEY_ABURST              => return READ_ARBURST; 
                when KEY_ALOCK               => return READ_ARLOCK;  
                when KEY_ACACHE              => return READ_ARCACHE; 
                when KEY_APROT               => return READ_ARPROT;  
                when KEY_AQOS                => return READ_ARQOS;   
                when KEY_AREGION             => return READ_ARREGION;
                when KEY_AUSER               => return READ_ARUSER;  
                when KEY_AID                 => return READ_ARID;    
                when KEY_AVALID              => return READ_ARVALID; 
                when KEY_AREADY              => return READ_ARREADY; 
                when KEY_RDATA               => return READ_RDATA;  
                when KEY_RRESP               => return READ_RRESP;  
                when KEY_RLAST               => return READ_RLAST;  
                when KEY_RUSER               => return READ_RUSER;  
                when KEY_RID                 => return READ_RID;    
                when KEY_RVALID              => return READ_RVALID; 
                when KEY_RREADY              => return READ_RREADY; 
                when others                  => null;
            end case;
        elsif (R or W) then
            case KEY_WORD is
                when KEY_ID         =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARID ;
                        when AXI4_CHANNEL_AW => return READ_AWID ;
                        when AXI4_CHANNEL_R  => return READ_RID  ;
                        when AXI4_CHANNEL_W  => return READ_WID  ;
                        when AXI4_CHANNEL_B  => return READ_BID  ;
                        when others          => null;
                    end case;
                when KEY_USER       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARUSER;
                        when AXI4_CHANNEL_AW => return READ_AWUSER;
                        when AXI4_CHANNEL_R  => return READ_RUSER;
                        when AXI4_CHANNEL_W  => return READ_WUSER;
                        when AXI4_CHANNEL_B  => return READ_BUSER;
                        when others          => null;
                    end case;
                when KEY_VALID      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARVALID;
                        when AXI4_CHANNEL_AW => return READ_AWVALID;
                        when AXI4_CHANNEL_R  => return READ_RVALID;
                        when AXI4_CHANNEL_W  => return READ_WVALID;
                        when AXI4_CHANNEL_B  => return READ_BVALID;
                        when others          => null;
                    end case;
                when KEY_READY      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREADY;
                        when AXI4_CHANNEL_AW => return READ_AWREADY;
                        when AXI4_CHANNEL_R  => return READ_RREADY;
                        when AXI4_CHANNEL_W  => return READ_WREADY;
                        when AXI4_CHANNEL_B  => return READ_BREADY;
                        when others          => null;
                    end case;
                when KEY_DATA       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RDATA;
                        when AXI4_CHANNEL_W  => return READ_WDATA;
                        when others          => null;
                    end case;
                when KEY_LAST       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RLAST;
                        when AXI4_CHANNEL_W  => return READ_WLAST;
                        when others          => null;
                    end case;
                when KEY_RESP       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_R  => return READ_RRESP;
                        when AXI4_CHANNEL_B  => return READ_BRESP;
                        when others          => null;
                    end case;
                when KEY_ADDR       => 
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARADDR; 
                        when AXI4_CHANNEL_AW => return READ_AWADDR; 
                        when others          => null;
                    end case;
                when KEY_LEN        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLEN; 
                        when AXI4_CHANNEL_AW => return READ_AWLEN; 
                        when others          => null;
                    end case;
                when KEY_SIZE       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARSIZE;
                        when AXI4_CHANNEL_AW => return READ_AWSIZE;
                        when others          => null;
                    end case;
                when KEY_BURST      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARBURST;
                        when AXI4_CHANNEL_AW => return READ_AWBURST;
                        when others          => null;
                    end case;
                when KEY_LOCK       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARLOCK;
                        when AXI4_CHANNEL_AW => return READ_AWLOCK;
                        when others          => null;
                    end case;
                when KEY_CACHE      =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARCACHE;
                        when AXI4_CHANNEL_AW => return READ_AWCACHE;
                        when others          => null;
                    end case;
                when KEY_PROT       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARPROT;
                        when AXI4_CHANNEL_AW => return READ_AWPROT;
                        when others          => null;
                    end case;
                when KEY_QOS        =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARQOS;
                        when AXI4_CHANNEL_AW => return READ_AWQOS;
                        when others          => null;
                    end case;
                when KEY_REGION     =>
                    case CHANNEL is
                        when AXI4_CHANNEL_AR => return READ_ARREGION;
                        when AXI4_CHANNEL_AW => return READ_AWREGION;
                        when others          => null;
                    end case;
                when KEY_STRB       =>
                    case CHANNEL is
                        when AXI4_CHANNEL_W  => return READ_WSTRB;
                        when others          => null;
                    end case;
                when KEY_ARADDR              => return READ_ARADDR;
                when KEY_ARLEN               => return READ_ARLEN; 
                when KEY_ARSIZE              => return READ_ARSIZE;
                when KEY_ARBURST             => return READ_ARBURST;
                when KEY_ARLOCK              => return READ_ARLOCK;
                when KEY_ARCACHE             => return READ_ARCACHE;
                when KEY_ARPROT              => return READ_ARPROT;
                when KEY_ARQOS               => return READ_ARQOS; 
                when KEY_ARREGION            => return READ_ARREGION;
                when KEY_ARUSER              => return READ_ARUSER;
                when KEY_ARID                => return READ_ARID;  
                when KEY_ARVALID             => return READ_ARVALID;
                when KEY_ARREADY             => return READ_ARREADY;
                when KEY_AWADDR              => return READ_AWADDR;
                when KEY_AWLEN               => return READ_AWLEN; 
                when KEY_AWSIZE              => return READ_AWSIZE;
                when KEY_AWBURST             => return READ_AWBURST;
                when KEY_AWLOCK              => return READ_AWLOCK;
                when KEY_AWCACHE             => return READ_AWCACHE;
                when KEY_AWPROT              => return READ_AWPROT;
                when KEY_AWQOS               => return READ_AWQOS; 
                when KEY_AWREGION            => return READ_AWREGION;
                when KEY_AWUSER              => return READ_AWUSER;
                when KEY_AWID                => return READ_AWID;  
                when KEY_AWVALID             => return READ_AWVALID;
                when KEY_AWREADY             => return READ_AWREADY;
                when KEY_RDATA               => return READ_RDATA;
                when KEY_RRESP               => return READ_RRESP;
                when KEY_RLAST               => return READ_RLAST;
                when KEY_RUSER               => return READ_RUSER;
                when KEY_RID                 => return READ_RID;  
                when KEY_RVALID              => return READ_RVALID;
                when KEY_RREADY              => return READ_RREADY;
                when KEY_WDATA               => return READ_WDATA;
                when KEY_WSTRB               => return READ_WSTRB;
                when KEY_WLAST               => return READ_WLAST;
                when KEY_WUSER               => return READ_WUSER;
                when KEY_WID                 => return READ_WID;  
                when KEY_WVALID              => return READ_WVALID;
                when KEY_WREADY              => return READ_WREADY;
                when KEY_BRESP               => return READ_BRESP;
                when KEY_BUSER               => return READ_BUSER;
                when KEY_BID                 => return READ_BID;  
                when KEY_BVALID              => return READ_BVALID;
                when KEY_BREADY              => return READ_BREADY;
                when others                  => null;
            end case;
        end if;
        return READ_NONE;
    end function;
    -------------------------------------------------------------------------------
    --! @brief KEY_WORD から READ_AXI4_SIGNAL_TYPEに変換する関数.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    KEY_WORD    キーワード.
    --! @return               変換されたREAD_AXI4_SIGNAL_TYPE.
    -------------------------------------------------------------------------------
    function  to_read_axi4_stream_signal(KEY_WORD: KEY_TYPE) return READ_AXI4_SIGNAL_TYPE is
    begin
        case KEY_WORD is
            when KEY_TDATA  | KEY_DATA  => return READ_TDATA;
            when KEY_TSTRB  | KEY_STRB  => return READ_TSTRB;
            when KEY_TKEEP  | KEY_KEEP  => return READ_TKEEP;
            when KEY_TUSER  | KEY_USER  => return READ_TUSER;
            when KEY_TDEST  | KEY_DEST  => return READ_TDEST;
            when KEY_TID    | KEY_ID    => return READ_TID;  
            when KEY_TLAST  | KEY_LAST  => return READ_TLAST;
            when KEY_TVALID | KEY_VALID => return READ_TVALID;
            when KEY_TREADY | KEY_READY => return READ_TREADY;
            when others                 => return READ_NONE;
        end case;
    end function;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションサイズの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    PROC_NAME   プロシージャ名.リードエラー発生時に出力する.
    --! @param    VAL         読み取ったトランザクションサイズの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_size(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  PROC_NAME     : in    string;
                  VAL           : inout AXI4_ASIZE_TYPE
    ) is
        variable  size          :       integer;
        variable  good          :       boolean;
    begin
        READ_INTEGER(CORE, STREAM, size, good);
        if (good) then
            case size is
                when    128 => VAL := AXI4_ASIZE_128BYTE;
                when     64 => VAL := AXI4_ASIZE_64BYTE;
                when     32 => VAL := AXI4_ASIZE_32BYTE;
                when     16 => VAL := AXI4_ASIZE_16BYTE;
                when      8 => VAL := AXI4_ASIZE_8BYTE;
                when      4 => VAL := AXI4_ASIZE_4BYTE;
                when      2 => VAL := AXI4_ASIZE_2BYTE;
                when      1 => VAL := AXI4_ASIZE_1BYTE;
                when others => READ_ERROR(CORE, PROC_NAME, "KEY=SIZE illegal number=" & INTEGER_TO_STRING(size));
            end case;
        else                   READ_ERROR(CORE, PROC_NAME, "KEY=SIZE READ_INTEGER not good");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションバースト長の値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    PROC_NAME   プロシージャ名.リードエラー発生時に出力する.
    --! @param    VAL         読み取ったトランザクションバースト長の値.
    -------------------------------------------------------------------------------
    procedure read_transaction_alen(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  PROC_NAME     : in    string;
                  VAL           : inout AXI4_ALEN_TYPE
    ) is
        variable  size          :       integer;
        variable  good          :       boolean;
    begin
        READ_INTEGER(CORE, STREAM, size, good);
        if (good) then
            VAL := std_logic_vector(to_unsigned(size-1, AXI4_ALEN_WIDTH));
        else
            READ_ERROR(CORE, PROC_NAME, "KEY=SIZE READ_INTEGER not good");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクション応答ステータスの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    PROC_NAME   プロシージャ名.リードエラー発生時に出力する.
    --! @param    VAL         読み取ったトランザクション応答ステータスの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_resp(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  PROC_NAME     : in    string;
                  VAL           : inout AXI4_RESP_TYPE
    ) is
        variable  key_word      :       KEY_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        SEEK_EVENT(CORE, STREAM, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            COPY_KEY_WORD(CORE, key_word);
            case key_word is
                when KEY_OKAY    => VAL := AXI4_RESP_OKAY  ;
                when KEY_EXOKAY  => VAL := AXI4_RESP_EXOKAY;
                when KEY_SLVERR  => VAL := AXI4_RESP_SLVERR;
                when KEY_DECERR  => VAL := AXI4_RESP_DECERR;
                when others      => READ_ERROR(CORE, PROC_NAME, "KEY=RESP illegal key_word=" & key_word);
            end case;
        else
            READ_ERROR(CORE, PROC_NAME, "KEY=RESP SEEK_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオからトランザクションバーストモードの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    PROC_NAME   プロシージャ名.リードエラー発生時に出力する.
    --! @param    VAL         読み取ったトランザクションバーストモードの値.
    -------------------------------------------------------------------------------
    procedure read_transaction_burst(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  PROC_NAME     : in    string;
                  VAL           : inout AXI4_ABURST_TYPE
    ) is
        variable  key_word      :       KEY_TYPE;
        variable  next_event    :       EVENT_TYPE;
    begin
        SEEK_EVENT(CORE, STREAM, next_event);
        if (next_event = EVENT_SCALAR) then
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            COPY_KEY_WORD(CORE, key_word);
            case key_word is
                when KEY_FIXED   => VAL := AXI4_ABURST_FIXED;
                when KEY_INCR    => VAL := AXI4_ABURST_INCR;
                when KEY_WRAP    => VAL := AXI4_ABURST_WRAP;
                when KEY_RESV    => VAL := AXI4_ABURST_RESV;
                when others      => READ_ERROR(CORE, PROC_NAME, "KEY=BURST illegal key_word=" & key_word);
            end case;
        else
            READ_ERROR(CORE, PROC_NAME, "KEY=BURST SEEK_EVENT NG");
        end if;
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからチャネル信号構造体の値を読み取るサブプログラム.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
    --!        しておかなければならない。
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    CHANNEL     チャネルのタイプ.
    --! @param    READ        リード可/不可を指定.
    --! @param    WRITE       ライト可/不可を指定.
    --! @param    WIDTH       チャネル信号のビット幅を指定する.
    --! @param    SIGNALS     読み取った値が入るレコード変数. inoutであることに注意.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_CHANNEL(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  CHANNEL       : in    AXI4_CHANNEL_TYPE;
                  READ          : in    boolean;
                  WRITE         : in    boolean;
                  WIDTH         : in    AXI4_SIGNAL_WIDTH_TYPE;
                  SIGNALS       : inout AXI4_CHANNEL_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    ) is
        constant  PROC_NAME     :       string := "MAP_READ_AXI4_CHANNEL";
        variable  next_event    :       EVENT_TYPE;
        variable  key_word      :       KEY_TYPE;
        procedure READ_VAL(VAL: out std_logic_vector) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
        begin
            SEEK_EVENT(CORE, STREAM, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(CORE, PROC_NAME, "READ_VAL NG");
            end if;
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => CORE.str_buf(1 to CORE.str_len),
                VAL     => VAL,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
        end procedure;
        procedure READ_VAL(VAL: out std_logic) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
            variable  vec           : std_logic_vector(0 downto 0);
        begin
            SEEK_EVENT(CORE, STREAM, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(CORE, PROC_NAME, "READ_VAL NG");
            end if;
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => CORE.str_buf(1 to CORE.str_len),
                VAL     => vec,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
            VAL := vec(0);
        end procedure;
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        next_event := EVENT;
        MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    COPY_KEY_WORD(CORE, key_word);
                    case to_read_axi4_channel_signal(key_word, CHANNEL, READ, WRITE) is
                        when READ_ARID     => READ_VAL(SIGNALS.AR.ID  (WIDTH.ID     -1 downto 0));
                        when READ_ARADDR   => READ_VAL(SIGNALS.AR.ADDR(WIDTH.ARADDR -1 downto 0));
                        when READ_ARLEN    => read_transaction_alen (CORE, STREAM, PROC_NAME, SIGNALS.AR.LEN  );
                        when READ_ARSIZE   => read_transaction_size (CORE, STREAM, PROC_NAME, SIGNALS.AR.SIZE );
                        when READ_ARBURST  => read_transaction_burst(CORE, STREAM, PROC_NAME, SIGNALS.AR.BURST);
                        when READ_ARLOCK   => READ_VAL(SIGNALS.AR.LOCK  );
                        when READ_ARCACHE  => READ_VAL(SIGNALS.AR.CACHE );
                        when READ_ARPROT   => READ_VAL(SIGNALS.AR.PROT  );
                        when READ_ARQOS    => READ_VAL(SIGNALS.AR.QOS   );
                        when READ_ARREGION => READ_VAL(SIGNALS.AR.REGION);
                        when READ_ARUSER   => READ_VAL(SIGNALS.AR.USER(WIDTH.ARUSER -1 downto 0));
                        when READ_ARVALID  => READ_VAL(SIGNALS.AR.VALID );
                        when READ_ARREADY  => READ_VAL(SIGNALS.AR.READY );
                        when READ_AWID     => READ_VAL(SIGNALS.AW.ID  (WIDTH.ID     -1 downto 0));
                        when READ_AWADDR   => READ_VAL(SIGNALS.AW.ADDR(WIDTH.ARADDR -1 downto 0));
                        when READ_AWLEN    => read_transaction_alen (CORE, STREAM, PROC_NAME, SIGNALS.AW.LEN  );
                        when READ_AWSIZE   => read_transaction_size (CORE, STREAM, PROC_NAME, SIGNALS.AW.SIZE );
                        when READ_AWBURST  => read_transaction_burst(CORE, STREAM, PROC_NAME, SIGNALS.AW.BURST);
                        when READ_AWLOCK   => READ_VAL(SIGNALS.AW.LOCK  );
                        when READ_AWCACHE  => READ_VAL(SIGNALS.AW.CACHE );
                        when READ_AWPROT   => READ_VAL(SIGNALS.AW.PROT  );
                        when READ_AWQOS    => READ_VAL(SIGNALS.AW.QOS   );
                        when READ_AWREGION => READ_VAL(SIGNALS.AW.REGION);
                        when READ_AWUSER   => READ_VAL(SIGNALS.AW.USER(WIDTH.ARUSER -1 downto 0));
                        when READ_AWVALID  => READ_VAL(SIGNALS.AW.VALID );
                        when READ_AWREADY  => READ_VAL(SIGNALS.AW.READY );
                        when READ_RID      => READ_VAL(SIGNALS.R.ID   (WIDTH.ID     -1 downto 0));
                        when READ_RUSER    => READ_VAL(SIGNALS.R.USER (WIDTH.RUSER  -1 downto 0));
                        when READ_RDATA    => READ_VAL(SIGNALS.R.DATA (WIDTH.RDATA  -1 downto 0));
                        when READ_RRESP    => read_transaction_resp(CORE, STREAM, PROC_NAME, SIGNALS.R.RESP);
                        when READ_RLAST    => READ_VAL(SIGNALS.R.LAST  );
                        when READ_RVALID   => READ_VAL(SIGNALS.R.VALID );
                        when READ_RREADY   => READ_VAL(SIGNALS.R.READY );
                        when READ_WID      => READ_VAL(SIGNALS.W.ID   (WIDTH.ID     -1 downto 0));
                        when READ_WUSER    => READ_VAL(SIGNALS.W.USER (WIDTH.WUSER  -1 downto 0));
                        when READ_WDATA    => READ_VAL(SIGNALS.W.DATA (WIDTH.WDATA  -1 downto 0));
                        when READ_WSTRB    => READ_VAL(SIGNALS.W.STRB (WIDTH.WDATA/8-1 downto 0));
                        when READ_WLAST    => READ_VAL(SIGNALS.W.LAST  );
                        when READ_WVALID   => READ_VAL(SIGNALS.W.VALID );
                        when READ_WREADY   => READ_VAL(SIGNALS.W.READY );
                        when READ_BID      => READ_VAL(SIGNALS.B.ID   (WIDTH.ID     -1 downto 0));
                        when READ_BUSER    => READ_VAL(SIGNALS.B.USER (WIDTH.BUSER  -1 downto 0));
                        when READ_BRESP    => read_transaction_resp(CORE, STREAM, PROC_NAME, SIGNALS.B.RESP);
                        when READ_BVALID   => READ_VAL(SIGNALS.B.VALID );
                        when READ_BREADY   => READ_VAL(SIGNALS.B.READY );
                        when others        => exit MAP_LOOP;
                    end case;
                when EVENT_MAP_END =>         exit MAP_LOOP;
                when others        =>         exit MAP_LOOP;
            end case;
            SEEK_EVENT(CORE, STREAM, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            end if;
        end loop;
        EVENT := next_event;
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからAXI4-Stream信号構造体の値を読み取るサブプログラム.
    --!      * このサブプログラムを呼ぶときは、すでにMAP_READ_BEGINを実行済みに
    --!        しておかなければならない。
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    WIDTH       チャネル信号のビット幅を指定する.
    --! @param    SIGNALS     読み取った値が入るレコード変数. inoutであることに注意.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_STREAM(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  WIDTH         : in    AXI4_STREAM_SIGNAL_WIDTH_TYPE;
                  SIGNALS       : inout AXI4_STREAM_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    ) is
        constant  PROC_NAME     :       string := "MAP_READ_AXI4_STREAM";
        variable  next_event    :       EVENT_TYPE;
        variable  key_word      :       KEY_TYPE;
        procedure READ_VAL(VAL: out std_logic_vector) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
        begin
            SEEK_EVENT(CORE, STREAM, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(CORE, PROC_NAME, "READ_VAL NG");
            end if;
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => CORE.str_buf(1 to CORE.str_len),
                VAL     => VAL,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
        end procedure;
        procedure READ_VAL(VAL: out std_logic) is
            variable  next_event    : EVENT_TYPE;
            variable  read_len      : integer;
            variable  val_size      : integer;
            variable  vec           : std_logic_vector(0 downto 0);
        begin
            SEEK_EVENT(CORE, STREAM, next_event  );
            if (next_event /= EVENT_SCALAR) then
                READ_ERROR(CORE, PROC_NAME, "READ_VAL NG");
            end if;
            READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            STRING_TO_STD_LOGIC_VECTOR(
                STR     => CORE.str_buf(1 to CORE.str_len),
                VAL     => vec,
                STR_LEN => read_len,
                VAL_LEN => val_size
            );
            VAL := vec(0);
        end procedure;
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        next_event := EVENT;
        MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    COPY_KEY_WORD(CORE, key_word);
                    case to_read_axi4_stream_signal(key_word) is
                        when READ_TDATA    => READ_VAL(SIGNALS.DATA(WIDTH.DATA  -1 downto 0));
                        when READ_TKEEP    => READ_VAL(SIGNALS.KEEP(WIDTH.DATA/8-1 downto 0));
                        when READ_TSTRB    => READ_VAL(SIGNALS.STRB(WIDTH.DATA/8-1 downto 0));
                        when READ_TUSER    => READ_VAL(SIGNALS.USER(WIDTH.USER  -1 downto 0));
                        when READ_TDEST    => READ_VAL(SIGNALS.DEST(WIDTH.DEST  -1 downto 0));
                        when READ_TID      => READ_VAL(SIGNALS.ID  (WIDTH.ID    -1 downto 0));
                        when READ_TLAST    => READ_VAL(SIGNALS.LAST  );
                        when READ_TVALID   => READ_VAL(SIGNALS.VALID );
                        when READ_TREADY   => READ_VAL(SIGNALS.READY );
                        when others        => exit MAP_LOOP;
                    end case;
                when EVENT_MAP_END =>         exit MAP_LOOP;
                when others        =>         exit MAP_LOOP;
            end case;
            SEEK_EVENT(CORE, STREAM, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            end if;
        end loop;
        EVENT := next_event;
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief シナリオのマップからトランザクションの値を読み取るサブプログラム.
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    CORE        コア変数.
    --! @param    STREAM      シナリオのストリーム.
    --! @param    ADDR_WIDTH  アドレスのビット幅.
    --! @param    AUSER_WIDTH ユーザー信号のビット幅.
    --! @param    DUSER_WIDTH ユーザー信号のビット幅.
    --! @param    BUSER_WIDTH ユーザー信号のビット幅.
    --! @param    ID_WIDTH    ID信号のビット幅.
    --! @param    TRANS       トランザクション信号.
    --! @param    EVENT       次のイベント. inoutであることに注意.
    -------------------------------------------------------------------------------
    procedure MAP_READ_AXI4_TRANSACTION(
        variable  CORE          : inout CORE_TYPE;
        file      STREAM        :       TEXT;
                  ADDR_WIDTH    : in    integer;
                  AUSER_WIDTH   : in    integer;
                  DUSER_WIDTH   : in    integer;
                  BUSER_WIDTH   : in    integer;
                  ID_WIDTH      : in    integer;
                  TRANS         : inout AXI4_TRANSACTION_SIGNAL_TYPE;
                  EVENT         : inout EVENT_TYPE
    ) is
        constant  PROC_NAME     :       string := "AXI4_CORE.MAP_READ_AXI4_TRANSACTION";
        variable  next_event    :       EVENT_TYPE;
        variable  key_word      :       KEY_TYPE;
        variable  len           :       integer;
        variable  pos           :       integer;
        variable  number_bytes  :       integer;
        variable  address       :       integer;
        variable  data_bytes    :       integer;
        variable  burst_len     :       integer;
    begin
        REPORT_DEBUG(CORE, PROC_NAME, "BEGIN");
        next_event := EVENT;
        pos        := TRANS.DATA_LEN;
        READ_MAP_LOOP: loop
            case next_event is
                when EVENT_SCALAR  =>
                    COPY_KEY_WORD(CORE, key_word);
                    REPORT_DEBUG(CORE, PROC_NAME, "KEY=" & key_word);
                    case key_word is
                        when KEY_SIZE   => read_transaction_size (CORE, STREAM, PROC_NAME, TRANS.SIZE );
                        when KEY_RESP   => read_transaction_resp (CORE, STREAM, PROC_NAME, TRANS.RESP );
                        when KEY_BURST  => read_transaction_burst(CORE, STREAM, PROC_NAME, TRANS.BURST);
                        when KEY_LOCK   => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.LOCK  , len);
                        when KEY_CACHE  => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.CACHE , len);
                        when KEY_PROT   => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.PROT  , len);
                        when KEY_QOS    => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.QOS   , len);
                        when KEY_REGION => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.REGION, len);
                        when KEY_ADDR   => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.ADDR (ADDR_WIDTH   -1 downto   0), len);
                        when KEY_AUSER  => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.AUSER(AUSER_WIDTH  -1 downto   0), len);
                        when KEY_DUSER  => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.DUSER(DUSER_WIDTH  -1 downto   0), len);
                        when KEY_BUSER  => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.BUSER(BUSER_WIDTH  -1 downto   0), len);
                        when KEY_ID     => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.ID   (ID_WIDTH     -1 downto   0), len);
                        when KEY_DATA   => READ_STD_LOGIC_VECTOR (CORE, STREAM, TRANS.DATA (TRANS.DATA'high downto pos), len);
                                           pos := pos + len;
                        when others     => exit READ_MAP_LOOP;
                    end case;
                when EVENT_MAP_END      => exit READ_MAP_LOOP;
                when others             => exit READ_MAP_LOOP;
            end case;
            SEEK_EVENT(CORE, STREAM, next_event);
            if (next_event = EVENT_SCALAR) then
                READ_EVENT(CORE, STREAM, EVENT_SCALAR);
            end if;
        end loop;
        EVENT          := next_event;
        TRANS.DATA_LEN := pos;
        TRANSACTION_TO_ADDR_AND_BYTES(TRANS, address, number_bytes);
        data_bytes := (pos+7)/8;
        burst_len  := (address + data_bytes + number_bytes - 1) / number_bytes;
        TRANS.LEN  := std_logic_vector(TO_UNSIGNED(burst_len-1, AXI4_ALEN_WIDTH));
        REPORT_DEBUG(CORE, PROC_NAME, "END");
    end procedure;
    -------------------------------------------------------------------------------
    --! @brief トランザクション情報からアドレスの下位ビットと１ワードのバイト数を生成
    --! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    --! @param    TRANS       トランザクション情報.
    --! @param    ADDR        アドレスの下位ビットの整数値.
    --! @param    SIZE        １ワードのバイト数.
    -------------------------------------------------------------------------------
    procedure TRANSACTION_TO_ADDR_AND_BYTES(
                  TRANS         : in    AXI4_TRANSACTION_SIGNAL_TYPE;
                  ADDR          : out   integer;
                  SIZE          : out   integer
    ) is
    begin
        case TRANS.SIZE is
            when AXI4_ASIZE_1BYTE   => SIZE :=   1; ADDR := 0;
            when AXI4_ASIZE_2BYTE   => SIZE :=   2; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(0 downto 0)));
            when AXI4_ASIZE_4BYTE   => SIZE :=   4; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(1 downto 0)));
            when AXI4_ASIZE_8BYTE   => SIZE :=   8; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(2 downto 0)));
            when AXI4_ASIZE_16BYTE  => SIZE :=  16; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(3 downto 0)));
            when AXI4_ASIZE_32BYTE  => SIZE :=  32; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(4 downto 0)));
            when AXI4_ASIZE_64BYTE  => SIZE :=  64; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(5 downto 0)));
            when AXI4_ASIZE_128BYTE => SIZE := 128; ADDR := TO_INTEGER(unsigned(TRANS.ADDR(6 downto 0)));
            when others             => SIZE :=   0; ADDR := 0;
        end case;
    end procedure;
end AXI4_CORE;
