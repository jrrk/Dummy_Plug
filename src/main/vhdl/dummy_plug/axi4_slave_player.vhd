-----------------------------------------------------------------------------------
--!     @file    axi4_slave_player.vhd
--!     @brief   AXI4 Slave Dummy Plug Player.
--!     @version 0.0.4
--!     @date    2012/5/7
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
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
entity  AXI4_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ            : --! @brief リードモードを指定する.
                          boolean   := TRUE;
        WRITE           : --! @brief ライトモードを指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    AXI4_ALEN_TYPE;
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    AXI4_ALOCK_TYPE;
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RVALID          : inout std_logic;
        RLAST           : inout std_logic;
        RDATA           : inout std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : inout AXI4_RESP_TYPE;
        RUSER           : inout std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    AXI4_ALEN_TYPE;
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    AXI4_ALOCK_TYPE;
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WVALID          : in    std_logic;
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BVALID          : inout std_logic;
        BUSER           : inout std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BRESP           : inout AXI4_RESP_TYPE;
        BID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        FINISH          : out   std_logic
    );
end AXI4_SLAVE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.SYNC.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    signal    sync_debug        : boolean   := FALSE;
    -------------------------------------------------------------------------------
    --! ローカル同期制御信号
    -------------------------------------------------------------------------------
    constant  SYNC_LOCAL_WAIT   : integer := 2;
    constant  SYNC_LOCAL_PORT   : integer := 0;
    signal    sync_local_signal : SYNC_SIG_TYPE;
    signal    sync_local_debug  : boolean := FALSE;
    signal    sync_m_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_m_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_ar_req       : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_ar_ack       : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_r_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_r_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_aw_req       : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_aw_ack       : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_w_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_w_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
    signal    sync_b_req        : SYNC_REQ_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT) := (others => 0);
    signal    sync_b_ack        : SYNC_ACK_VECTOR(SYNC_LOCAL_PORT downto SYNC_LOCAL_PORT);
begin
    -------------------------------------------------------------------------------
    -- メイン用のプレイヤー
    -------------------------------------------------------------------------------
    M: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME,
            CHANNEL         => AXI4_CHANNEL_M,
            MASTER          => FALSE,
            SLAVE           => FALSE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_req    , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_m_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_m_ack  , -- In :
            FINISH          => FINISH        -- Out:
        );
    -------------------------------------------------------------------------------
    -- リードアドレスチャネルプレイヤー
    -------------------------------------------------------------------------------
    AR: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".AR",
            CHANNEL         => AXI4_CHANNEL_AR,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => ARREADY     , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_ar_req , -- Out:
            SYNC_LOCAL_ACK  => sync_ar_ack , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- リードデータチャネルプレイヤー
    -------------------------------------------------------------------------------
    R: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".R",
            CHANNEL         => AXI4_CHANNEL_R,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => RVALID      , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => RLAST       , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => RDATA       , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => RRESP       , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => RUSER       , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => RID         , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_r_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_r_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルプレイヤー
    -------------------------------------------------------------------------------
    AW: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".AW",
            CHANNEL         => AXI4_CHANNEL_AW,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => AWREADY     , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_aw_req , -- Out:
            SYNC_LOCAL_ACK  => sync_aw_ack , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライトデータチャネルプレイヤー
    -------------------------------------------------------------------------------
    W: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".W",
            CHANNEL         => AXI4_CHANNEL_W,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => WREADY      , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => open        , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => open        , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => open        , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => open        , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_w_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_w_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライト応答チャネルプレイヤー
    -------------------------------------------------------------------------------
    B: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => NAME,
            FULL_NAME       => NAME & ".B",
            CHANNEL         => AXI4_CHANNEL_B,
            MASTER          => FALSE,
            SLAVE           => TRUE,
            READ            => READ,
            WRITE           => WRITE,
            OUTPUT_DELAY    => OUTPUT_DELAY,
            WIDTH           => WIDTH,
            SYNC_WIDTH      => SYNC_WIDTH,
            SYNC_LOCAL_PORT => SYNC_LOCAL_PORT,
            SYNC_LOCAL_WAIT => SYNC_LOCAL_WAIT,
            FINISH_ABORT    => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK        , -- In :
            ARESETn         => ARESETn     , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I        => ARADDR      , -- In :
            ARADDR_O        => open        , -- Out:
            ARLEN_I         => ARLEN       , -- In :
            ARLEN_O         => open        , -- Out:
            ARSIZE_I        => ARSIZE      , -- In :
            ARSIZE_O        => open        , -- Out:
            ARBURST_I       => ARBURST     , -- In :
            ARBURST_O       => open        , -- Out:
            ARLOCK_I        => ARLOCK      , -- In :
            ARLOCK_O        => open        , -- Out:
            ARCACHE_I       => ARCACHE     , -- In :
            ARCACHE_O       => open        , -- Out:
            ARPROT_I        => ARPROT      , -- In :
            ARPROT_O        => open        , -- Out:
            ARQOS_I         => ARQOS       , -- In :
            ARQOS_O         => open        , -- Out:
            ARREGION_I      => ARREGION    , -- In :
            ARREGION_O      => open        , -- Out:
            ARUSER_I        => ARUSER      , -- In :
            ARUSER_O        => open        , -- Out:
            ARID_I          => ARID        , -- In :
            ARID_O          => open        , -- Out:
            ARVALID_I       => ARVALID     , -- In :
            ARVALID_O       => open        , -- Out:
            ARREADY_I       => ARREADY     , -- In :
            ARREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I        => RVALID      , -- In :
            RVALID_O        => open        , -- Out:
            RLAST_I         => RLAST       , -- In :
            RLAST_O         => open        , -- Out:
            RDATA_I         => RDATA       , -- In :
            RDATA_O         => open        , -- Out:
            RRESP_I         => RRESP       , -- In :
            RRESP_O         => open        , -- Out:
            RUSER_I         => RUSER       , -- In :
            RUSER_O         => open        , -- Out:
            RID_I           => RID         , -- In :
            RID_O           => open        , -- Out:
            RREADY_I        => RREADY      , -- In :
            RREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I        => AWADDR      , -- In :
            AWADDR_O        => open        , -- Out:
            AWLEN_I         => AWLEN       , -- In :
            AWLEN_O         => open        , -- Out:
            AWSIZE_I        => AWSIZE      , -- In :
            AWSIZE_O        => open        , -- Out:
            AWBURST_I       => AWBURST     , -- In :
            AWBURST_O       => open        , -- Out:
            AWLOCK_I        => AWLOCK      , -- In :
            AWLOCK_O        => open        , -- Out:
            AWCACHE_I       => AWCACHE     , -- In :
            AWCACHE_O       => open        , -- Out:
            AWPROT_I        => AWPROT      , -- In :
            AWPROT_O        => open        , -- Out:
            AWQOS_I         => AWQOS       , -- In :
            AWQOS_O         => open        , -- Out:
            AWREGION_I      => AWREGION    , -- In :
            AWREGION_O      => open        , -- Out:
            AWUSER_I        => AWUSER      , -- In :
            AWUSER_O        => open        , -- Out:
            AWID_I          => AWID        , -- In :
            AWID_O          => open        , -- Out:
            AWVALID_I       => AWVALID     , -- In :
            AWVALID_O       => open        , -- Out:
            AWREADY_I       => AWREADY     , -- In :
            AWREADY_O       => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I        => WVALID      , -- In :
            WVALID_O        => open        , -- Out:
            WLAST_I         => WLAST       , -- In :
            WLAST_O         => open        , -- Out:
            WDATA_I         => WDATA       , -- In :
            WDATA_O         => open        , -- Out:
            WSTRB_I         => WSTRB       , -- In :
            WSTRB_O         => open        , -- Out:
            WUSER_I         => WUSER       , -- In :
            WUSER_O         => open        , -- Out:
            WID_I           => WID         , -- In :
            WID_O           => open        , -- Out:
            WREADY_I        => WREADY      , -- In :
            WREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I        => BVALID      , -- In :
            BVALID_O        => BVALID      , -- Out:
            BRESP_I         => BRESP       , -- In :
            BRESP_O         => BRESP       , -- Out:
            BUSER_I         => BUSER       , -- In :
            BUSER_O         => BUSER       , -- Out:
            BID_I           => BID         , -- In :
            BID_O           => BID         , -- Out:
            BREADY_I        => BREADY      , -- In :
            BREADY_O        => open        , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ        => open        , -- Out:
            SYNC_ACK        => sync_ack    , -- In :
            SYNC_LOCAL_REQ  => sync_b_req  , -- Out:
            SYNC_LOCAL_ACK  => sync_b_ack  , -- In :
            FINISH          => open          -- Out:
        );
    -------------------------------------------------------------------------------
    -- このコア用の同期回路
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => string'("SLAVE:SYNC"),
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => ACLK,                -- In :
                RST      => sync_rst,            -- In :
                CLR      => sync_clr,            -- In :
                DEBUG    => sync_debug,          -- In :
                SYNC     => SYNC(i),             -- I/O:
                REQ      => sync_req(i),         -- In :
                ACK      => sync_ack(i)          -- Out:
            );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
    -------------------------------------------------------------------------------
    -- このコア内部のローカルな同期回路
    -------------------------------------------------------------------------------
    SYNC_LOCAL : SYNC_LOCAL_HUB 
        generic map (
            NAME     => string'("SLAVE:SYNC_LOCAL_HUB"),
            PLUG_SIZE=> 6
        )
        port map (
            CLK      => ACLK,
            RST      => sync_rst,
            CLR      => sync_clr,
            DEBUG    => sync_local_debug,
            SYNC     => sync_local_signal,
            REQ(1)   => sync_m_req (SYNC_LOCAL_PORT),
            REQ(2)   => sync_ar_req(SYNC_LOCAL_PORT),
            REQ(3)   => sync_r_req (SYNC_LOCAL_PORT),
            REQ(4)   => sync_aw_req(SYNC_LOCAL_PORT),
            REQ(5)   => sync_w_req (SYNC_LOCAL_PORT),
            REQ(6)   => sync_b_req (SYNC_LOCAL_PORT),
            ACK(1)   => sync_m_ack (SYNC_LOCAL_PORT),
            ACK(2)   => sync_ar_ack(SYNC_LOCAL_PORT),
            ACK(3)   => sync_r_ack (SYNC_LOCAL_PORT),
            ACK(4)   => sync_aw_ack(SYNC_LOCAL_PORT),
            ACK(5)   => sync_w_ack (SYNC_LOCAL_PORT),
            ACK(6)   => sync_b_ack (SYNC_LOCAL_PORT)
        );
  -- U_SYNC_PRINT : SYNC_PRINT generic map (NAME => NAME) port map (SYNC => sync_local_signal);
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
